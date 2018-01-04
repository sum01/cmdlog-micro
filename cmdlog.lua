VERSION = "1.0.0"

-- A true/false option for displaying as a vsplit instead of hsplit
if GetOption("cmdlog-vertical") == nil then
	-- default to horizontal
	AddOption("cmdlog-vertical", false)
end

local log_view = nil
local cmd_list = {}

-- Opens an empty hsplit and sets its settings
local function new_view()
	-- Open an empty view horizontally/vertically
	if GetOption("cmdlog-vertical") then
		CurView():VSplit(NewBuffer("", "cmdlog"))
		-- Save the view to track it
		log_view = CurView()
		-- Keep the width to 30% (lower than this is kind of hard to read)
		log_view.Width = 30
		-- Don't let it be changed
		log_view.LockWidth = true
	else
		CurView():HSplit(NewBuffer("", "cmdlog"))
		-- Save the view to track it
		log_view = CurView()
		-- Keep the height to 10%
		log_view.Height = 10
		-- Don't let it be changed
		log_view.LockHeight = true
	end

	SetLocalOption("softwrap", "true", log_view)
	-- Line numbering
	SetLocalOption("ruler", "true", log_view)
	-- Is this needed with new non-savable settings from being "vtLog"?
	SetLocalOption("autosave", "false", log_view)
	-- Don't show the statusline to differentiate the view from normal views
	SetLocalOption("statusline", "false", log_view)
	SetLocalOption("scrollbar", "false", log_view)
	-- Read-only and no-save (a "vtScratch" type)
	-- Requires Micro >= v1.3.5
	log_view.Type.Kind = 2
	log_view.Type.Readonly = true
	log_view.Type.Scratch = true
	-- Resize after setting height
	tabs[curTab + 1]:Resize()
end

local function close_log()
	if log_view ~= nil then
		log_view:Quit(false)
		log_view = nil
	end
end

function log_it(input)
	-- Since this is public, we make sure the log_view actually exists
	assert(log_view ~= nil, "The cmdlog view doesn't exist!")

	-- Print the input into the log
	log_view.Buf:insert(Loc(0, log_view.Buf:LinesNum() - 1), input .. "\n")
end

-- Empty placeholder for JobSpawn
function onExit()
	return true
end

-- Closed current
function preQuit(view)
	if view == log_view then
		-- A fake quit function
		close_log()
		-- Don't actually "quit", otherwise it closes everything without saving for some reason
		return false
	end
end

-- Closed all
function preQuitAll(view)
	close_log()
end

function run_in_order()
	-- Safety-check there's actually anything to run
	if next(cmd_list) == nil then
		do
			return
		end
	end
	-- This all goes before JobSpawn to avoid any potential race-condition
	local command = cmd_list[1].cmd
	local args = cmd_list[1].args
	-- Remove the first command+args
	local new_cmdlist = {}
	-- By starting at 2, we "delete" the first, since it gets skipped
	for i = 2, #cmd_list do
		new_cmdlist[i - 1] = cmd_list[i]
	end
	-- Replace the current list with our updated values
	cmd_list = new_cmdlist

	-- Run the command, and print anything it spits out
	-- By using run_in_order as the onExit, we avoid the Goroutines proccessing something before the first is done
	JobSpawn(command, args, "cmdlog.log_it", "cmdlog.log_it", "cmdlog.run_in_order")
end

-- Actually parses and runs the command
local function parse_cmd(input)
	local command
	local args = {}
	local is_first = true
	-- Split the command by spaces
	for word in input:gmatch("%S+") do
		if is_first then
			-- Get the real, base command
			command = word
			is_first = false
		else
			-- Append the args into a table (JobSpawn requires args as a table)
			args[#args + 1] = word
		end
	end

	-- Save the command, and its args, to be eventually run
	cmd_list[#cmd_list + 1] = {
		["cmd"] = command,
		["args"] = args
	}
end

function runit(input)
	-- Require a command to actually run
	if input == nil then
		messenger:Error("cmdlog: You need to input something to run")
		do
			return
		end
	end

	-- If no open cmdlog, open an empty one
	if log_view == nil then
		new_view()
	else
		-- Create a visual separator between command "chunks" (when `runit` is run)
		log_it("~~~~~~~~~~~~\n")
		-- Move the cursor to the bottom before inserting the command results
		log_view.Buf.Cursor:DownN(log_view.Buf:LinesNum() - 1 - log_view.Buf.Cursor.Loc.Y)
	end

	-- Clear the command list before inserting anything
	cmd_list = {}

	local contains_separator = false
	-- Preparser for separating by semi-colons
	for separated in input:gmatch("[^;]+") do
		contains_separator = true
		parse_cmd(separated)
	end
	-- If no semi-colon is passed, just parse as normal
	if not contains_separator then
		parse_cmd(input)
	end

	-- Loop through command(s) and run them with JobSpawn
	run_in_order()
end

-- A non-local function for the user to (optionally) bind to allow for easy `runit` input (without quotes)
function prompt_runit()
	local input, cancel = messenger:Prompt("runit: ", "", 0)
	if input ~= nil and not cancel then
		runit(input)
	end
end

MakeCommand("runit", "cmdlog.runit", 0)
AddRuntimeFile("cmdlog", "help", "help/cmdlog.md")
