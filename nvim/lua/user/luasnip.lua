-- require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/my_snippets" })
require("luasnip.loaders.from_vscode").lazy_load()
-- require("luasnip.loaders.from_vscode").load({ paths = "~/gitprojects/vscode_petal_components_snippets" })

require("luasnip").filetype_extend("heex", { "html" })

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local c = ls.choice_node
local i = ls.insert_node

ls.add_snippets("heex", {
	s("container", {
		t("<.container max_width="),
		c(1, {
			t("sm"),
			t("md"),
			t("lg"),
			t("xl"),
			t("full"),
		}),
		t(">"),
		i(2),
		t("</.container>"),
	}),
})

--[
--"<.container max_width=\"${1:sm|md|lg|xl|full}\">",
--"  $0",
-- "</.container>"
