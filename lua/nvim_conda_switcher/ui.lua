-- Copyright (C) 2025-10-16 Nana Zhao
-- lua/nvim_conda_switcher/ui.lua
-- =========================================================
-- Conda 环境选择浮窗 UI
-- =========================================================

local M = {}

local ns_id = vim.api.nvim_create_namespace("CondaSwitcher")
local ns_cursor = vim.api.nvim_create_namespace("CondaSwitcherCursor")

local function center(str, width)
	local pad = math.floor((width - #str) / 2)
	return string.rep(" ", pad) .. str
end

------------------------------------------------------------
-- 绘制浮动窗口
------------------------------------------------------------
function M.open_env_selector()
	local core = require("nvim_conda_switcher.core")
	local envs = core.get_env_list()
	if not envs or #envs == 0 then
		vim.notify("[conda-switcher] 没有找到任何 Conda 环境。", vim.log.levels.WARN)
		return
	end

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.min(#envs + 6, math.floor(vim.o.lines * 0.5))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- local lines = {}
	-- table.insert(lines, center("Conda Environments", width))
	-- table.insert(lines, string.rep("─", width))
	-- for i, env in ipairs(envs) do
	-- 	local name = env:match("([^/]+)$") or env
	-- 	table.insert(lines, string.format(" [%d] %-20s %s", i, name, env))
	-- end
	-- table.insert(lines, string.rep("─", width))
	-- table.insert(lines, " ↑/↓ 移动  Enter 选择  q 退出 ")
	-- table.insert(lines, string.rep("─", width))
	--
	-- vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	-- vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 0, 0, -1)
	local lines = {}
	table.insert(lines, center("Conda Environments", width))
	table.insert(lines, string.rep("─", width))

	local current_env = vim.env.CONDA_PREFIX or ""
	local current_env_line = nil

	for i, env in ipairs(envs) do
		local name = env:match("([^/]+)$") or env
		table.insert(lines, string.format(" [%d] %-20s %s", i, name, env))
		if current_env ~= "" and env == current_env then
			current_env_line = #lines
		end
	end

	table.insert(lines, string.rep("─", width))
	table.insert(lines, " ↑/↓ 移动  Enter 选择  q 退出 ")
	table.insert(lines, string.rep("─", width))

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- 标题高亮
	vim.api.nvim_buf_add_highlight(buf, ns_id, "Title", 0, 0, -1)

	-- 当前环境黄色高亮
	if current_env_line then
		vim.api.nvim_buf_add_highlight(buf, ns_id, "WarningMsg", current_env_line - 1, 0, -1)
	end

	-- 当前选中项
	local current_line = 3
	vim.api.nvim_win_set_cursor(win, { current_line, 0 })

	-- local function highlight_line(line)
	-- 	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
	-- 	vim.api.nvim_buf_add_highlight(buf, ns_id, "Visual", line - 1, 0, -1)
	-- end
	local function highlight_line(line)
		vim.api.nvim_buf_clear_namespace(buf, ns_cursor, 0, -1)
		vim.api.nvim_buf_add_highlight(buf, ns_cursor, "Visual", line - 1, 0, -1)
	end
	highlight_line(current_line)

	------------------------------------------------------------
	-- 键盘交互
	------------------------------------------------------------
	vim.keymap.set("n", "j", function()
		if current_line < #envs + 2 then
			current_line = current_line + 1
			vim.api.nvim_win_set_cursor(win, { current_line, 0 })
			highlight_line(current_line)
		end
	end, { buffer = buf, nowait = true })

	vim.keymap.set("n", "k", function()
		if current_line > 3 then
			current_line = current_line - 1
			vim.api.nvim_win_set_cursor(win, { current_line, 0 })
			highlight_line(current_line)
		end
	end, { buffer = buf, nowait = true })

	vim.keymap.set("n", "<CR>", function()
		local selected = envs[current_line - 2]
		vim.api.nvim_win_close(win, true)
		core.switch_env(selected)
	end, { buffer = buf, nowait = true })

	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, nowait = true })
end

return M
