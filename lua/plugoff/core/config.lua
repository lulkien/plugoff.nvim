local Util = require("plugoff.core.util")

local M = {}

M.defaults = {
	-- Where plugins will be installed.
	root = vim.fn.stdpath("data") .. "/plugoff",

	-- Where packages will be downloaded
	cache = vim.fn.stdpath("cache") .. "/plugoff",

	-- Default proxy config
	proxy = {
		enable = false,
		http = nil,
		https = nil,
		auth = nil,
	},
}

M.plugins = {}

return M
