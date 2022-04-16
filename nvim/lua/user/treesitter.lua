local treeSitterConfigs = require("nvim-treesitter.configs")

treeSitterConfigs.setup({
	ensure_installed = "maintained",
	highlight = {
		enable = true,
	},
})