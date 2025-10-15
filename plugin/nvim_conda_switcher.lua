-- Copyright (C) 2025-10-15 Nana Zhao
-- plugin/nvim_conda_switcher.lua
-- =========================================================
-- 注册 Neovim 用户命令（公开插件功能）
-- =========================================================
--
-- vim.api.nvim_create_user_command("CondaSwitch", function(opts)
-- 	local core = require("nvim_conda_switcher.core")
--
-- 	-- 如果提供了路径参数，直接切换
-- 	if opts.args and opts.args ~= "" then
-- 		core.switch_env(opts.args)
-- 		return
-- 	end
--
-- 	-- 否则列出所有环境并提示用户
-- 	local envs = core.get_env_list()
-- 	if #envs == 0 then
-- 		vim.notify("[conda-switcher] 未找到任何 Conda 环境。", vim.log.levels.WARN)
-- 		return
-- 	end
--
-- 	local msg = "请选择 Conda 环境路径:\n"
-- 	for i, env in ipairs(envs) do
-- 		msg = msg .. string.format(" [%d] %s\n", i, env)
-- 	end
-- 	vim.notify(msg, vim.log.levels.INFO)
-- end, {
-- 	nargs = "?", -- 参数可选
-- 	complete = "file", -- 路径补全
-- })
--

vim.api.nvim_create_user_command("CondaSwitch", function(opts)
	local core = require("nvim_conda_switcher.core")
	local ui = require("nvim_conda_switcher.ui")

	-- 如果用户输入了路径参数，直接切换
	if opts.args and opts.args ~= "" then
		core.switch_env(opts.args)
		return
	end

	-- 否则打开浮窗 UI
	ui.open_env_selector()
end, {
	nargs = "?", -- 参数可选
	complete = "file", -- 支持路径补全
})
