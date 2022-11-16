vim.o.quickfixtextfunc = "v:lua.require'quickfix.format'.shorten"

vim.keymap.set("n", "]q", ":<C-U>exe v:count1 . 'cnext'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[q", ":<C-U>exe v:count1 . 'cprev'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "]l", ":<C-U>exe v:count1 . 'lnext'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[l", ":<C-U>exe v:count1 . 'lprev'<CR>", { remap = false, silent = true })

vim.keymap.set("n", "]Q", ":<C-U>exe v:count1 . 'cnewer'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[Q", ":<C-U>exe v:count1 . 'colder'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "]L", ":<C-U>exe v:count1 . 'lnewer'<CR>", { remap = false, silent = true })
vim.keymap.set("n", "[L", ":<C-U>exe v:count1 . 'lolder'<CR>", { remap = false, silent = true })
