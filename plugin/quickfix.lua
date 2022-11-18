if vim.g.loaded_quickfix ~= nil then
	return
end
vim.g.loaded_quickfix = true

vim.o.quickfixtextfunc = "v:lua.require'sencer.format'.shorten"

vim.keymap.set("n", "]q", ":<C-U>exe v:count1 . 'cnext'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[q", ":<C-U>exe v:count1 . 'cprev'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "]l", ":<C-U>exe v:count1 . 'lnext'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[l", ":<C-U>exe v:count1 . 'lprev'<CR>", { remap = false, silent = true })

vim.keymap.set("n", "]Q", ":<C-U>exe v:count1 . 'cnewer'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[Q", ":<C-U>exe v:count1 . 'colder'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "]L", ":<C-U>exe v:count1 . 'lnewer'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[L", ":<C-U>exe v:count1 . 'lolder'<CR>", { remap = false, silent = true })

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

-- When any window is closed check if:
--   There is only a single window left & that window is quickfix or loclist window.
--   If that's the case, and we have other buffers, load one of those.
vim.api.nvim_create_autocmd("WinClosed", {
	pattern = "*",
	nested = true,
	group = "QuickfixSettings",
	callback = function()
		if vim.fn.winnr("$") > 2 then
			return
		end

		local winnr = vim.fn.winnr() == 1 and 2 or 1

		local typ = vim.fn.win_gettype(winnr)

		if not (typ == "quickfix" or typ == "loclist") then
			return
		end

		for buf = 1, vim.fn.bufnr("$") do
			if buf ~= vim.fn.bufnr() and vim.fn.buflisted(buf) == 1 then
				vim.cmd("wincmd w | b " .. buf .. "|cwin" .. bounded(#vim.fn.getqflist()) .. "|wincmd p")
				return
			end
		end
	end,
})
