local Config = require("packoff.core.config")
local Plugin = require("packoff.core.plugin")
local Util = require("packoff.core.util")

local M = {}

function M.setup(plugins, opts)
	-- Extend default config with user's config
	opts = vim.tbl_deep_extend("force", Config.defaults, opts or {})

	-- Check valid proxy
	local proxy = opts.proxy
	if proxy.enable then
		-- If http proxy is not set, it will get from environment
		proxy.http = proxy.http or vim.env.http_proxy
		-- If https proxy is not set, it will get from env, the env is not set, it will take the http_proxy
		proxy.https = proxy.https or vim.env.https_proxy or proxy.http
		-- If http or https proxy is not valid -> dont use proxy
		proxy.enable = proxy.http and proxy.https
	end

	Plugin.load(plugins, opts)
end

return M
