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
		for i = input.start_idx, input.end_idx do
			table.insert(formatted, fn(items[i]))
		end
		return formatted
	end
	return formatter
end

M.text = M.wrap(function(item)
	return item.text
end)

M.shorten = M.wrap(function(item)
	local lnum = (item.lnum and item.lnum > 0) and tostring(item.lnum) or ""
	local col = (item.col and item.col > 0) and tostring(item.col) or ""
	local bufname = item.bufnr > 0 and vim.fn.bufname(item.bufnr) or ""
	local filename = bufname ~= "" and vim.fn.pathshorten(bufname) or ""
	return table.concat({
		filename,
		lnum,
		col,
		item.text,
	}, "|")
end)

return M
