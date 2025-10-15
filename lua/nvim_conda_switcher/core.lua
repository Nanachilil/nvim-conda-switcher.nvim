-- Copyright (C) 2025-10-15 Nana Zhao
-- =========================================================
-- 业务核心模块：与 Conda 环境交互 + LSP 环境刷新（纯 Neovim 原生）
-- =========================================================

local M = {}

------------------------------------------------------------
-- 获取所有 Conda 环境列表
-- 调用系统命令：conda env list --json
-- 返回: { "/opt/anaconda3", "/opt/anaconda3/envs/myenv", ... }
------------------------------------------------------------
function M.get_env_list()
	-- 调用命令
	local handle = io.popen("conda env list --json 2>/dev/null")
	if not handle then
		vim.notify(
			"[conda-switcher] 无法执行 conda 命令，请检查是否已安装 Conda。",
			vim.log.levels.ERROR
		)
		return {}
	end

	local output = handle:read("*a")
	handle:close()

	if output == "" or output == nil then
		vim.notify("[conda-switcher] Conda 输出为空，可能未配置 PATH。", vim.log.levels.WARN)
		return {}
	end

	-- JSON 解析
	local ok, data = pcall(vim.json.decode, output)
	if not ok or not data or not data.envs then
		vim.notify("[conda-switcher] 解析 Conda JSON 失败：" .. tostring(output), vim.log.levels.ERROR)
		return {}
	end

	return data.envs
end

------------------------------------------------------------
-- 切换 Conda 环境 + 刷新 Neovim 自带 LSP
-- 参数: env_path (string) - Conda 环境路径
------------------------------------------------------------
function M.switch_env(env_path)
	if not env_path or env_path == "" then
		vim.notify("[conda-switcher] 无效的 Conda 环境路径。", vim.log.levels.ERROR)
		return
	end

	------------------------------------------------------------
	-- 1️⃣ 更新 Neovim 运行环境变量
	------------------------------------------------------------
	vim.env.CONDA_PREFIX = env_path
	vim.env.PATH = env_path .. "/bin:" .. vim.env.PATH
	vim.g.python3_host_prog = env_path .. "/bin/python"

	local env_name = env_path:match("([^/]+)$") or env_path
	vim.notify("✅ 已切换到 Conda 环境: " .. env_name, vim.log.levels.INFO)

	------------------------------------------------------------
	-- 2️⃣ 刷新 Neovim 内置 LSP 客户端（不依赖 lspconfig）
	------------------------------------------------------------
	local clients = vim.lsp.get_active_clients()
	if #clients == 0 then
		vim.notify("[conda-switcher] 当前没有正在运行的语言服务器。", vim.log.levels.WARN)
		return
	end

	for _, client in pairs(clients) do
		local cfg = client.config
		vim.lsp.stop_client(client.id, true)

		-- 延迟重启，确保新 PATH 已被系统识别
		vim.defer_fn(function()
			vim.lsp.start_client(cfg)
		end, 100)
	end

	vim.notify("🔄 所有 LSP 已在新 Conda 环境中重启。", vim.log.levels.INFO)
end

return M
