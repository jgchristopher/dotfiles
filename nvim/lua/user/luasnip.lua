-- require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/my_snippets" })
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/gitprojects/vscode_petal_components_snippets" })

require("luasnip").filetype_extend("heex", { "html" })
