return {
  "stevearc/overseer.nvim",
  dependencies = { "akinsho/toggleterm.nvim" },
  config = function()
    local terminal = require("toggleterm.terminal")
    local util = require("overseer.util")

    -- Define the Strategy Class
    local ToggleTermStrategy = {}
    ToggleTermStrategy.__index = ToggleTermStrategy

    -- Overseer calls .new() for EVERY task
    function ToggleTermStrategy.new()
      return setmetatable({
        chan_id = nil,
        term = nil,
      }, ToggleTermStrategy)
    end

    function ToggleTermStrategy:start(task)
      local stdout_iter = util.get_stdout_line_iter()

      self.term = terminal.Terminal:new({
        cmd = task.cmd,
        cwd = task.cwd,
        env = task.env,
        direction = "float", -- Force the float
        close_on_exit = false,
        on_stdout = function(j, d)
          task:dispatch("on_output", d)
          local lines = stdout_iter(d)
          if not vim.tbl_isempty(lines) then
            task:dispatch("on_output_lines", lines)
          end
        end,
        on_exit = function(j, c)
          if vim.v.exiting == vim.NIL then
            task:on_exit(c)
          end
        end,
      })

      -- This is the critical part: Spawn starts the process and attaches the ID
      self.term:spawn()
      self.chan_id = self.term.job_id

      -- Open the window immediately so you see it
      self.term:open()
    end

    function ToggleTermStrategy:stop()
      if self.term then
        self.term:shutdown()
      end
    end

    function ToggleTermStrategy:dispose()
      self:stop()
    end

    require("overseer").setup({
      -- PASS THE CLASS TABLE, NOT AN INSTANCE
      -- Overseer will call ToggleTermStrategy.new() internally
      strategy = ToggleTermStrategy,
    })
  end,
}
