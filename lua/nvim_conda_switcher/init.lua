-- Copyright (C) 2025-10-15 Nana Zhao
-- lua/nvim_conda_switcher/init.lua
-- ============================================================
-- 插件入口模块（防崩溃版本）
-- ============================================================

local M = {}

------------------------------------------------------------
-- 基础配置（可以在外部 require("nvim_conda_switcher").setup(opts) 调用）
------------------------------------------------------------
function M.setup(opts)
	opts = opts or {}
	-- 默认配置
	M.config = vim.tbl_deep_extend("force", {
		notify = true, -- 是否启用通知提示
		auto_log = false, -- 是否自动输出日志
	}, opts)

	if M.config.notify then
		vim.notify("[conda-switcher] loaded successfully!", vim.log.levels.INFO)
	end

	-- 尝试加载核心模块（容错处理）
	local ok_core, core = pcall(require, "nvim_conda_switcher.core")
	if not ok_core then
		vim.notify("[conda-switcher] failed to load core: " .. tostring(core), vim.log.levels.ERROR)
	else
		M.core = core
	end

	-- 尝试加载 UI 模块
	local ok_ui, ui = pcall(require, "nvim_conda_switcher.ui")
	if not ok_ui then
		vim.notify("[conda-switcher] failed to load UI: " .. tostring(ui), vim.log.levels.WARN)
	else
		M.ui = ui
	end
end

------------------------------------------------------------
-- 供外部命令直接调用（即使没 setup 也不报错）
------------------------------------------------------------
function M.open_picker()
	if M.ui and M.ui.open_picker then
		M.ui.open_picker()
	else
		vim.notify("[conda-switcher] UI not available.", vim.log.levels.WARN)
	end
end

------------------------------------------------------------
-- 返回模块
------------------------------------------------------------
return M
