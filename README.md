# packoff.nvim

Lightweight plugin manager for Neovim.

## Feature

If your company does not allow you to clone anything from github, this might help :D

This plugin use wget to download package instead of git clone.

Can be configurated to use proxy.

## Requirements

- Neovim >= 0.8.0
- Wget
- Unzip
- [Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) (optional)

## Installation

You can add the following Lua code to your `init.lua` to bootstrap **packoff.nvim**:

```lua
-- Bootstrap Packoff
local packoff_path = vim.fn.stdpath("data") .. "/packoff/packoff.nvim"

if not vim.loop.fs_stat(packoff_path) then
	-- Bootstrap packoff
	local repo = "http://10.176.127.158:3000/kienlh4ivi/packoff.nvim"
	local result = vim.system({
		"git",
		"clone",
		repo,
		"--branch=master",
		packoff_path,
	}):wait()

	if result.code ~= 0 then
		print("git: " .. result.stderr)
	end
end

if vim.loop.fs_stat(packoff_path) then
	vim.opt.rtp:prepend(packoff_path)
	require("configs.packoff")
end
```

Next step is to add **packoff.nvim** below the code added in the prior step in `init.lua`:

```lua
require("packoff").setup(plugins, opts)
```

- **plugins**: This should be a table. (A list of [PluginSpec](#-PluginSpec))
- **opts**: See [Configuration](#-Configuration). (optional)

## PluginSpec
|Properties|Type|Description|
|----------|----|-----------|
|`name`|`string`| Plugin name |
|`url`|`string` or `nil`| URL to download plugin |
|`config`|`fun()` or `nil`|Function will run when plugin is successfully loaded|

## Example plugins

```lua
{
    {
		name = "catppucin",
		url = "https://github.com/catppuccin/nvim/archive/refs/tags/v1.6.0.zip",
		-- Install theme, no need to config
	},
    {
		name = "conform.nvim",
		url = "https://github.com/stevearc/conform.nvim/archive/refs/tags/v5.5.0.zip",
		config = function()
			require("conform").setup({
	            formatters_by_ft = {
		            lua = { "stylua" },
		            sh = { "shfmt" },
		            fish = { "fish_indent" },
	            },
	            format_on_save = {
		            -- These options will be passed to conform.format()
		            timeout_ms = 500,
		            lsp_fallback = true,
	            },
            })
		end,
	},
    {
		name = "nvim-autopairs",
		url = "https://github.com/windwp/nvim-autopairs/archive/refs/heads/master.zip",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
}
```

## Configuration

**packoff.nvim** comes with the following defaults:

```lua
{
	-- Where plugins will be installed
	root = vim.fn.stdpath("data") .. "/packoff",

	-- Where packages will be downloaded
	cache = vim.fn.stdpath("cache") .. "/packoff",

	-- Default proxy config
	proxy = {
		enable = false,
		http = nil,
		https = nil,
		auth = {
            username = nil,
            password = nil,
        },
	},
}
```

