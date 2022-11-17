local M = {}

-- An easy way to create quickfixtextfunc. Receives a function to map a quickfix item to a string that will be used to
-- display it; creates a quickfixtextfunc that can be passed to setqflist & setloclist.
M.wrap = function(fn)
	local formatter = function(input)
		local items
		if input.quickfix == 1 then
			items = vim.fn.getqflist({ id = input.id, items = 1 }).items
		else
			items = vim.fn.getloclist(input.winid, { id = input.id, items = 1 }).items
		end
		local formatted = {}
		for _, item in pairs(vim.list_slice(items, input.start_idx, input.end_idx)) do
			table.insert(formatted, fn(item))
		end
		return formatted
	end
	return formatter
end

M.text = M.wrap(function(item)
	return item.text
end)

M.shorten = M.wrap(function(item)
	return table.concat({
		vim.fn.pathshorten(vim.fn.bufname(item.bufnr)),
		item.lnum or "",
		item.col or "",
		item.text,
	}, "|")
end)

return M
