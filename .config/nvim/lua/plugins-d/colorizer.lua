require("colorizer").setup(
    {
      "vim",
      "sh",
      "zsh",
      "markdown",
      "tmux",
      "yaml",
      "xml",
      lua = { names = false },
    }, {
      RGB = false,
      RRGGBB = true,
      RRGGBBAA = true,
      names = false,
      mode = "background",
    }
)
