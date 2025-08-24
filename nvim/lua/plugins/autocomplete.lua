return {
  {
    "Exafunction/codeium.vim",
    lazy = false, -- Load immediately on startup
    config = function()
      vim.g.codeium_enabled = true -- Enable Codeium right away
    end,
  },
}
