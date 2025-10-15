-- Copyright (C) 2025-10-15 Nana Zhao
-- =========================================================
-- 业务核心模块：与 Conda 环境交互
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
-- 切换 Conda 环境
-- 修改当前 Neovim 的运行环境变量
-- 参数: env_path (string) - Conda 环境路径
------------------------------------------------------------
function M.switch_env(env_path)
	if not env_path or env_path == "" then
		vim.notify("[conda-switcher] 无效的 Conda 环境路径。", vim.log.levels.ERROR)
		return
	end

	-- 更新环境变量
	vim.env.CONDA_PREFIX = env_path
	vim.env.PATH = env_path .. "/bin:" .. vim.env.PATH
	vim.g.python3_host_prog = env_path .. "/bin/python"

	-- 提取环境名
	local env_name = env_path:match("([^/]+)$") or env_path

	-- 提示
	vim.notify("✅ 已切换到 Conda 环境: " .. env_name, vim.log.levels.INFO)
end

return M
