local Util = require("plugoff.core.util")

local M = {}

function M.load(plugins, opts)
	for _, plugin in ipairs(plugins) do
		local plugin_installed = Util.check_plugin_installed(opts, plugin)
		local download_ok = nil
		local install_ok = nil

		if not plugin_installed then
			-- Download package or check if the package was downloaded
			download_ok = Util.download_package(opts, plugin)
			if download_ok then
				install_ok = Util.install_package(opts, plugin)
			end
		end

		-- Add PATH into rtp if installed
		if plugin_installed or install_ok then
			vim.opt.rtp:prepend(opts.root .. "/" .. plugin.name)
			if plugin.config then
				plugin.config()
			end
		end
	end
end

return M
