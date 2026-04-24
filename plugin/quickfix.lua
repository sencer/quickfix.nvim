if vim.g.loaded_quickfix ~= nil then
	return
end
vim.g.loaded_quickfix = true

vim.o.quickfixtextfunc = "v:lua.require'sencer.format'.shorten"

local function map(lhs, cmd, desc)
	vim.keymap.set("n", lhs, function()
		pcall(vim.cmd, vim.v.count1 .. cmd)
	end, { desc = desc, silent = true })
end

map("]q", "cnext", "Next quickfix item")
map("[q", "cprev", "Previous quickfix item")
map("]l", "lnext", "Next loclist item")
map("[l", "lprev", "Previous loclist item")

map("]Q", "cnewer", "Newer quickfix list")
map("[Q", "colder", "Older quickfix list")
map("]L", "lnewer", "Newer loclist")
map("[L", "lolder", "Older loclist")

local function bounded(numitems)
	return math.max(1, math.min(10, numitems))
end

vim.api.nvim_create_augroup("QuickfixSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	group = "QuickfixSettings",
	command = "setlocal number norelativenumber wrap nobuflisted nospell colorcolumn=",
})

-- Close loclist if parent window is closed + open loclist automatically when populated with auto-adjusted size.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = "l*",
	callback = function()
		local winid = vim.fn.win_getid()
		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = tostring(winid),
			command = "silent lclose",
			once = true,
			group = "QuickfixSettings",
		})
		vim.cmd("lwin " .. bounded(#vim.fn.getloclist(winid)))
	end,
})

-- Open quickfix automatically when populated with auto-adjusted size.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = "[^l]*",
	group = "QuickfixSettings",
	callback = function()
		vim.cmd("cwin " .. bounded(#vim.fn.getqflist()))
	end,
})

-- Cleanly close Vim if quickfix or loclist is the last window.
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	group = "QuickfixSettings",
	callback = function()
		if vim.fn.winnr("$") == 1 then
			local typ = vim.fn.win_gettype()
			if typ == "quickfix" or typ == "loclist" then
				vim.cmd("quit")
			end
		end
	end,
})
