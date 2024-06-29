local M = {}

function M.debug(msg)
	vim.notify(msg, vim.log.levels.DEBUG)
end

function M.error(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

function M.check_plugin_installed(opts, plugin)
	local install_path = opts.root .. "/" .. plugin.name
	local stat = vim.loop.fs_stat(install_path)

	return stat and stat.type or false
end

function M.check_package_downloaded(opts, plugin)
	local downloaded_path = opts.cache .. "/" .. plugin.name .. ".zip"
	local stat = vim.loop.fs_stat(downloaded_path)

	return stat and stat.type or false
end

local function trim(str)
	return str:match("^%s*(.-)%s*$")
end

local function do_download_with_proxy(proxy, package_url, download_path)
	if proxy.auth then
		return vim.system({
			"wget",
			"-e",
			"use_proxy=yes",
			"-e",
			"http_proxy=" .. proxy.http,
			"-e",
			"https_proxy=" .. proxy.https,
			"--proxy-user=" .. proxy.auth.username,
			"--proxy-password=" .. proxy.auth.password,
			"--no-check-certificate",
			"--output-document=" .. download_path,
			package_url,
		}):wait()
	else
		return vim.system({
			"wget",
			"-e",
			"use_proxy=yes",
			"-e",
			"http_proxy=" .. proxy.http,
			"-e",
			"https_proxy=" .. proxy.https,
			"--no-check-certificate",
			"--output-document=" .. download_path,
			package_url,
		}):wait()
	end
end

local function do_download(package_url, download_path)
	return vim.system({
		"wget",
		"--no-proxy",
		"--no-check-certificate",
		"--output-document=" .. download_path,
		package_url,
	}):wait()
end

function M.install_package(opts, plugin)
	local system = vim.system
	local temp_path = "/tmp/plugoff/download"
	local package_path = opts.cache .. "/" .. plugin.name .. ".zip"
	local install_path = opts.root .. "/" .. plugin.name

	-- Create {temp_path}
	system({ "mkdir", "-p", temp_path }):wait()

	-- Unzip package from {package_path} into {temp_path}
	local unzip_result = system({ "unzip", package_path, "-d", temp_path }, { text = true }):wait()
	if unzip_result.code ~= 0 then
		system({ "rm", "-r", temp_path }):wait()
		M.error("unzip: " .. unzip_result.stderr)
		M.error("Failed to install " .. plugin.name)
		M.error("---------------------------------------")
		return false
	end

	-- Find extracted path: {output_path}
	local result = system({ "ls", temp_path }, { text = true }):wait()
	local output_path = temp_path .. "/" .. trim(result.stdout)

	-- Move everything in {output_path} into {install_path}
	local mv_result = system({ "mv", output_path, install_path }, { text = true }):wait()
	if mv_result.code ~= 0 then
		system({ "rm", "-r", temp_path }):wait()
		M.error("mv: " .. mv_result.stderr)
		M.error("Failed to install " .. plugin.name)
		M.error("---------------------------------------")
		return false
	end

	-- Clean up {temp_path}
	system({ "rm", "-rf", temp_path }):wait()

	-- Log
	M.debug(plugin.name .. " is installed.")
	M.debug("---------------------------------------")

	return true
end

function M.download_package(opts, plugin)
	local result = {}
	local download_path = opts.cache .. "/" .. plugin.name .. ".zip"

	if vim.loop.fs_stat(download_path) then
		M.debug("Package " .. plugin.name .. " is downloaded.")
		return true
	end

	M.debug("Downloading package: " .. plugin.name)
	vim.system({ "mkdir", "-p", opts.cache }):wait()
	if opts.proxy.enable then
		result = do_download_with_proxy(opts.proxy, plugin.url, download_path)
	else
		result = do_download(plugin.url, download_path)
	end

	if result.code ~= 0 then
		M.error("wget: " .. result.stderr)
		M.error("Failed to download package " .. plugin.name)
		return false
	end

	return true
end

return M
