-- ---------------------------------------------------------------------------
-- AstroNvim bootstrap via lazy.nvim
-- ---------------------------------------------------------------------------
local uv = vim.uv or vim.loop

-- A root invocation here (accidental `sudo nvim`, or a misbehaving system
-- activation script) would clone/write the plugin cache as root, leaving it
-- unwritable by the real user afterwards and breaking lazy.nvim's git
-- operations (checkout/update) for every plugin, permanently.
if uv.os_getuid and uv.os_getuid() == 0 then
	vim.api.nvim_echo({
		{ "AstroNvim: refusing to manage plugins while running as root.\n", "ErrorMsg" },
		{ "Re-run nvim as your normal user to avoid corrupting ~/.local/share/nvim ownership.", "WarningMsg" },
	}, true, {})
	return
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to continue..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
require("lazy_setup")
