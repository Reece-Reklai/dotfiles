local harpoon
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2", -- Temp; Will be merged soonish 🔥
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		harpoon = require("harpoon"):setup() -- Notice we're storing to parent context 👆
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "add to harpoon list" })
		vim.keymap.set("n", "<C-h>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", "<C-q>", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<C-e>", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<C-s>", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<C-t>", function()
			harpoon:list():select(4)
		end)
	end,
}
