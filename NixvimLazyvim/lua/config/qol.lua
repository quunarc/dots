local map = vim.keymap.set
local themes = { "ayu-dark", "noctishc" }  -- Make sure you use "noctishc" correctly
local current_theme = 2

function ToggleTheme()
    current_theme = 3 - current_theme  -- Toggles between 1 and 2
    vim.cmd("colorscheme " .. themes[current_theme])
    vim.g.current_theme = current_theme  -- Save state
    vim.notify("Switched to " .. themes[current_theme], vim.log.levels.INFO)
end

vim.keymap.set("n", ".", ToggleTheme, { noremap = true, silent = true, desc = "Toggle Theme" })

vim.cmd [[
  highlight WhichKey guibg=NONE
  highlight WhichKeyFloat guibg=NONE
  highlight WhichKeyBorder guibg=NONE
  highlight WhichKeySeparator guibg=NONE
  highlight Special guibg=NONE
  highlight SnacksDashboardDesc guibg=NONE
]]

-- local Util = require("lazyvim.util")
--
-- Override LazyVim's root detection function to include CMakeLists.txt
-- function Util.root.get(path, patterns)
--     patterns = patterns or { ".git", "CMakeLists.txt", "Makefile", "build" } -- Add CMake files
--     return require("lazyvim.util.root").find(path or vim.fn.getcwd(), patterns)
-- end

vim.api.nvim_create_user_command("Search", function (opts)

    local args = vim.split(opts.args, " ")

    if #args < 2 then return end

    local search = vim.fn.escape(args[1], '\\/')
    local replace = args[2]

    vim.cmd('%s/\\<'..search..'\\>/'..replace..'/g')

end, {nargs="*"})

-- config/wakatime.lua
local Job = require("plenary.job")
local async = require("plenary.async")
local uv = vim.loop

local get_wakatime_time = function()
	local tx, rx = async.control.channel.oneshot()
	local ok, job = pcall(Job.new, Job, {
		command = os.getenv("HOME") .. "/.wakatime/wakatime-cli",
		args = { "--today" },
		on_exit = function(j, _)
			tx(j:result()[1] or "")
		end,
	})
	if not ok then
		vim.notify("Bad WakaTime call: " .. job, vim.log.levels.WARN)
		return ""
	end

	job:start()
	return rx()
end

local state = { comp_wakatime_time = "" }

local Wakatime_routine_init = false

local wakatime = function()
	local WAKATIME_UPDATE_INTERVAL = 10000

	if not Wakatime_routine_init then
		local timer = uv.new_timer()
		if timer == nil then
			return ""
		end

		uv.timer_start(timer, 500, WAKATIME_UPDATE_INTERVAL, function()
			local function format_wakatime_output(time)
				if not time or time == "" then
					return ""
				end
				local hours = time:match("(%d+)%s*hr")
				if hours then
					return hours .. "h Coding"
				end

				local mins = time:match("(%d+)%s*min")
				if mins then
					return mins .. "m Coding"
				end
				return ""
			end

			async.run(get_wakatime_time, function(time)
				state.comp_wakatime_time = format_wakatime_output(time)
			end)
		end)

		Wakatime_routine_init = true
	end

	return state.comp_wakatime_time
end

return wakatime
