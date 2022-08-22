local M = {}

-- requires repo extension
function M.repo_list()
  local opts = {}
  opts.prompt_title = " Repos"
  require("telescope").extensions.repo.list(opts)
end

return M
