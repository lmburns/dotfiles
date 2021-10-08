-- Mostly copied from https://github.com/RustemB/xplr
local function setup()
  xplr.config.node_types.directory.meta.icon = "📁"
  xplr.config.node_types.file.meta.icon = "📜"
  xplr.config.node_types.symlink.meta.icon = "🔗"
  xplr.config.node_types.mime_essence = {
    ["text"] = {
      ["plain"] = {
        meta = { icon = "📄" },
      }
    },
    ["video"] = {
      ["*"] = {
        meta = { icon = "📽" },
      }
    }
  }
  xplr.config.node_types.extension = {
    py = {
      meta = { icon = "🐍" },
    },
    hy = {
      meta = { icon = "🐙" },
    },
    hs = {
      meta = { icon = "λ" },
    },
    rs = {
      meta = { icon = "🦀" },
    },
    lua = {
      meta = { icon = "🌙" },
    },
    lock = {
      meta = { icon = "🔒" },
    },
  }
  xplr.config.node_types.special = {
    ["Cargo.toml"] = {
      meta = { icon = "⚙" },
    },
    ["PKGBUILD"] = {
      meta = { icon = "🛠 "},
    },
  }
end

return { setup = setup }
