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

vim.api.nvim_create_autocmd("WinClosed", {
	pattern = "*",
	group = "QuickfixSettings",
	callback = function()
		vim.schedule(function()
			local wins = vim.api.nvim_list_wins()
			if #wins == 1 then
				local buf = vim.api.nvim_win_get_buf(wins[1])
				if vim.bo[buf].buftype == "quickfix" then
					vim.cmd("qa")
				end
			end
		end)
	end,
})
