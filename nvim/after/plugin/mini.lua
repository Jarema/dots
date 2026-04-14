require('mini.files').setup()
vim.keymap.set('n', '<leader>o', MiniFiles.open, {})

require('mini.comment').setup()

require('mini.pairs').setup()

require('mini.surround').setup({
    mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
    },
})
