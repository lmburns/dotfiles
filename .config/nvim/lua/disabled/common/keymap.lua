return setmetatable(
    {
      nore = { noremap = true, silent = false, expr = false },
      remap = { noremap = false, silent = true, expr = false },
    }, {
      __index = function(p, mode)
        return setmetatable(
            {
              map = function(key, action, opts)
                opts = opts or p.remap
                opts.noremap = opts.noremap == nil and false or opts.noremap
                vim.api.nvim_set_keymap(mode, key, action, opts)
              end,
              nmap = function(key, action, opts)
                vim.api.nvim_set_keymap(mode, key, action, opts)
              end,
              bmap = function(buf, key, action, opts)
                vim.api.nvim_buf_set_keymap(buf, mode, key, action, opts)
              end,
            }, {
              __call = function(this, key, action, opts)
                opts = opts or p.nore
                opts.noremap = opts.noremap == nil and true or opts.noremap
                this.nmap(key, action, opts)
              end,
            }
        )
      end,
    }
)
