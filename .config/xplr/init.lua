version = "0.17.2"

-- == HELP == {{{
-- BashExec: {command: bash, args: ["-c", "${command}"], silent: false}
-- PopMode: Pop the last mode from the history and switch to it.
-- SwitchModeBuiltin: Switch to a builtin mode.
-- SwitchModeCustom: Switch to a custom mode.
-- ChangeDirectory: Change the present working directory ($PWD)
-- FocusPath: Focus on the given path.
-- Enter: Enter into the currently focused path if it’s a directory.
-- ClearScreen: clears screen
-- ExplorePwdAsync: explore CWD and register filtered nodes async
-- Call: e.g., {command: bash, args: ["-c", "read -p test"]}
-- -c: shell escaped
-- may need to pass ExplorePwd depending on expectation

-- XPLR_PIPE_MSG_IN:  read messages from other programs
-- XPLR_FOCUS_PATH:  write focused node path for other progs
-- XPLR_PIPE_SELECTION_OUT: write new-line delim selected paths for other progs
-- XPLR_PIPE_GLOBAL_HELP_MENU_OUT:  write global help menu for anyone to read
-- XPLR_PIPE_LOGS_OUT: write logs for anyone to read
-- XPLR_PIPE_RESULT_OUT: write current result (selection or focused path)
-- XPLR_PIPE_DIRECTORY_NODES_OUT: write abspath of filtered nodes in CWD
-- XPLR_PIPE_HISTORY_OUT: dynamic history of last visited directories
-- Examples:
-- echo ChangeDirectory: /tmp >> "${XPLR_PIPE_MSG_IN:?}"
-- echo FocusNext >> "${XPLR_PIPE_MSG_IN:?}"
-- }}} == HELP ==

-- #####################################################################

-- package.path = os.getenv("XDG_CONFIG_HOME") .. '/xplr/plugins/?/src/init.lua'
-- package.path = os.getenv("HOME") .. "/.config/xplr/plugins/?/src/init.lua"

-- require("icons").setup {}
-- require("completion").setup()

-- require("scroll").setup {}
--
-- require("alacritty").setup {
--   mode = "default",
--   key = "ctrl-n",
--   send_focus = true,
--   send_selection = true,
--   extra_alacritty_args = "",
--   extra_xplr_args = ""
-- }

-- require("nnn_preview").setup {
--   plugin_path = os.getenv("HOME") .. "/.config/nnn/plugins/preview-tui",
--   fifo_path = "/tmp/xplr.fifo",
--   mode = "action",
--   key = "p"
-- }
--
-- -- require("fzf").setup{
-- --   mode = "default",
-- --   key = "F",
-- --   args = "--preview 'pistol {}'"
-- -- }
--
-- require("zoxide").setup {mode = "default", key = "n"}

local xplr = xplr

xplr.config.general.enable_mouse = true
xplr.config.general.show_hidden = true
xplr.config.general.enable_recover_mode = false

-- xplr.config.modes.builtin.action.key_bindings.on_key["C"] = {
--   help = "edit config",
--   messages = {
--     { BashExec = "$EDITOR ~/.config/xplr/init.lua" },
--   },
-- }

xplr.config.modes.builtin.go_to.key_bindings.on_key.p = {
  help = "go to path",
  messages = {
    "PopMode", { SwitchModeCustom = "go_to_path" }, { SetInputBuffer = "" }
  }
}

xplr.config.modes.custom.go_to_path = {
  name = "go to path",
  key_bindings = {
    on_key = {
      enter = { messages = { "FocusPathFromInput", "PopMode" } },
      esc = { help = "cancel", messages = { "PopMode" } },
      tab = {
        help = "complete",
        messages = { { CallLuaSilently = "custom.completion.complete_path" } }
      },
      ["ctrl-c"] = { help = "terminate", messages = { "Terminate" } },
      backspace = {
        help = "remove last character",
        messages = { "RemoveInputBufferLastCharacter" }
      },
      ["ctrl-u"] = {
        help = "remove line",
        messages = { { SetInputBuffer = "" } }
      },
      ["ctrl-w"] = {
        help = "remove last word",
        messages = { "RemoveInputBufferLastWord" }
      }
    },
    default = { messages = { "BufferInputFromKey" } }
  }
}

--
-- -- == functions == {{{
-- -------- Function equivalent to basename in POSIX systems
-- xplr.fn.custom.basename = function(path)
--   return string.gsub(path, "(.*/)(.*)", "%2")
-- end
--
-- -------- Function equivalent to dirname in POSIX systems
-- xplr.fn.custom.dirname = function(path)
--   if str:match(".-/.-") then
--     local name = string.gsub(path, "(.*/)(.*)", "%1")
--     return name
--   else
--     return ''
--   end
-- end
--
-- -------- Shell escape. See https://github.com/ncopa/lua-shell
-- xplr.fn.custom.shell_escape = function(args)
--   local ret = {}
--   for _, a in pairs(args) do
--     local s = tostring(a)
--     if s:match("[^A-Za-z0-9_/:=-]") then
--       s = "'" .. s:gsub("'", "'\\''") .. "'"
--     end
--     table.insert(ret, s)
--   end
--   return table.concat(ret, " ")
-- end
--
-- -------- Shell run. See https://github.com/ncopa/lua-shell
-- xplr.fn.custom.shell_run = function(args)
--   local h = io.popen(xplr.fn.builtin.shell_escape(args))
--   local outstr = h:read("*a")
--   return h:close(), outstr
-- end
--
-- -------- Shell execute. See https://github.com/ncopa/lua-shell
-- xplr.fn.custom.shell_execute = function(args)
--   return os.execute(xplr.fn.builtin.shell_escape(args))
-- end
-- -- }}} == functions ==

-- ##########################################################################

-- KEYS: default mode {{{
local key = xplr.config.modes.builtin.default.key_bindings.on_key

key.e = xplr.config.modes.builtin.action.key_bindings.on_key.e -- open editor
key.o = xplr.config.modes.builtin.go_to.key_bindings.on_key.x -- open gui
key.L = key["ctrl-i"] -- next visited path
key.H = key["ctrl-o"] -- prev visited path
key["ctrl-i"] = nil
key["ctrl-o"] = nil

key.c = xplr.config.modes.builtin.action.key_bindings.on_key.c -- create mode

-- TODO: get dirname of current dir on exit if selection is file
-- key.enter = {
--   help = "print dir",
--   messages = {
--     { BashExec = [[ cat "${XPLR_PIPE_DIRECTORY_NODES_OUT:?}" ]] }
--   }
-- }

-- shell
key['!'] = {
  help = "shell",
  messages = {
    { Call = { command = "zsh", args = { "-i", "-l" } } }, "ExplorePwdAsync",
    "PopMode"
  }
}

-- disk usage
-- key.D = { help = "disk usage",
--   messages = { { Call = { command = "ncdu" } }, "ClearScreen" }, }

-- Usage: dua i
key.D = {
  help = "disk usage",
  messages = { { BashExec = [[dua i]] }, "ClearScreen" }
}

-- Usage: dust
key.S = {
  help = "folder sizes",
  messages = {
    { BashExec = [[dust && read -p "[enter to continue]"]] }, "PopMode"
  }
}

-- Preview: fzf
key["ctrl-f"] = {
  help = "search with preview",
  messages = {
    {
      BashExec = [===[
      PTH=$(cat "${XPLR_PIPE_DIRECTORY_NODES_OUT:?}" \
        | awk -F / '{print $NF}' \
        | fzf --preview-window ":nohidden")
      if [ -d "$PTH" ]; then
        echo ChangeDirectory: "'"$PWD/${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
      elif [ -f "$PTH" ]; then
        echo FocusPath: "'"$PWD/${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
      fi
      ]===]
    }
  }
}

-- History: fuzzy
key["ctrl-h"] = {
  help = "fzf history",
  messages = {
    {
      BashExec = [===[
      PTH=$(cat "${XPLR_PIPE_HISTORY_OUT:?}" | sort -u | fzf --no-sort)
      if [ -e "$PTH" ]; then
        echo ChangeDirectory: "'"${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
      fi
    ]===]
    }
  }
}

-- Rename: batch rename
key.R = {
  help = "batch rename",
  messages = {
    {
      BashExec = [[
      SELECTION=$(cat "${XPLR_PIPE_SELECTION_OUT:?}")
      NODES=${SELECTION:-$(cat "${XPLR_PIPE_DIRECTORY_NODES_OUT:?}")}
      if [ "$NODES" ]; then
        echo -e "$NODES" | pipe-renamer
        echo ExplorePwdAsync >> "${XPLR_PIPE_MSG_IN:?}"
      fi
    ]]
    }
  }
}

-- Copy: binding
key.y = {help = "copy", messages = {"PopMode", {SwitchModeCustom = "copy"}}}

-- -- Paste: binding
-- key.p = {
--   help = "paste",
--   messages = {
--     {
--       BashExecSilently = [[
--       xclip-pastefile > /dev/null && echo ExplorePwdAsync >> "${XPLR_PIPE_MSG_IN:?}"
--       ]]
--     }
--   }
-- }
--
-- -- New Session: alacritty
-- key["ctrl-n"] = {
--   help = "new session",
--   messages = {
--     {
--       BashExecSilently = [[
--       alacritty -e tmux
--     ]]
--     }
--   }
-- }
--
-- -- Paste: paste.rs binding
-- key.P = {
--   help = "paste.rs",
--   messages = {"PopMode", {SwitchModeCustom = "paste.rs"}}
-- }
--
-- -- FZXPLR: custom fuzzy
-- key.F = {help = "fzf mode", messages = {{SwitchModeCustom = "fzxplr"}}}
--
-- -- F2: binding
-- key.O = {
--   help = "f2: organize",
--   messages = {"PopMode", {SwitchModeCustom = "f2"}}
-- }
--
-- -- Bookmark: mode binding
-- key.b = {
--   help = "bookmark manager",
--   messages = {{SwitchModeCustom = "bookmark"}}
-- }
-- -- }}} === default mode ===
--
-- -- KEYS: action mode {{{
-- actkey = xplr.config.modes.builtin.action.key_bindings.on_key
--
-- actkey.e = nil
-- actkey.l = {
--   help = "logs",
--   messages = {
--     {BashExec = [[ cat -- "${XPLR_PIPE_LOGS_OUT}" | less -+F ]]}, "PopMode"
--   }
-- }
--
-- actkey.C = {
--   help = "edit config",
--   messages = {{BashExec = "${EDITOR} $XDG_CONFIG_HOME/xplr/init.lua"}}
-- }
-- -- }}} === action mode ===
--
-- -- KEYS: delete mode  {{{
-- delkey = xplr.config.modes.builtin.delete.key_bindings.on_key
--
-- -- Trash: delete
-- delkey.d = {
--   help = "delete",
--   messages = {
--     {
--       BashExecSilently = [===[
--         while IFS= read -r line; do trash-put -- "${line:?}";
--         done < "${XPLR_PIPE_RESULT_OUT:?}"
--         echo ExplorePwdAsync >> "${XPLR_PIPE_MSG_IN:?}"
--         terminal-notifier -title "🗑️  File(s) deleted" -message "File(s) moved to trash"
--         ]===]
--     }, "PopMode"
--   }
-- }
--
-- -- Trash: restore
-- delkey.r = {
--   help = "restore delete",
--   messages = {
--     {
--       BashExec = [===[
--       ftr; echo ExplorePwdAsync >> "${XPLR_PIPE_MSG_IN:?}"
--       ]===]
--     }, "PopMode"
--   }
-- }
-- -- }}} === delete mode ==
--
-- -- KEYS: go to {{{
-- gokey = xplr.config.modes.builtin.go_to.key_bindings.on_key
--
-- gokey.k = gokey.g
-- gokey.j = xplr.config.modes.builtin.default.key_bindings.on_key.G
-- gokey.x = nil
--
-- -- go to directory
-- gokey.c = {
--   help = "go to config dir",
--   messages = {
--     {
--       BashExecSilently = [[
--       echo 'ChangeDirectory: "/home/lucas/.config"' >> "${XPLR_PIPE_MSG_IN:?}"
--     ]]
--     }
--   }
-- }
--
-- -- Jump: formarks (taken from wfxr zsh plugin)
-- gokey.b = {
--   help = "bookmark jump",
--   messages = {
--     {
--       BashExec = [===[
--     field='\(\S\+\s*\)'
--     esc=$(printf '\033')
--     N="${esc}[0m"
--     R="${esc}[31m"
--     G="${esc}[32m"
--     Y="${esc}[33m"
--     B="${esc}[34m"
--     pattern="s#^${field}${field}${field}${field}#$Y\1$R\2$N\3$B\4$N#"
--     PTH=$(sed 's#: # -> #' "$PATHMARKS_FILE"| nl| column -t \
--     | gsed "${pattern}" \
--     | fzf --ansi \
--         --height '40%' \
--         --preview="echo {}|sed 's#.*->  ##'| xargs exa --color=always" \
--         --preview-window="right:50%" \
--     | sed 's#.*->  ##')
--     if [ "$PTH" ]; then
--       echo ChangeDirectory: "'"${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
--     fi
--     ]===]
--     }
--   }
-- }
-- -- }}} === go to mode ===
--
-- -- MODES: custom {{{
-- cmodes = xplr.config.modes.custom
-- -- fzxplr
-- cmodes["fzxplr"] = {
--   name = "fzxplr",
--   key_bindings = {
--     on_key = {
--       F = {
--         help = "search",
--         messages = {
--           {
--             BashExec = [===[
--             PTH=$(cat "${XPLR_PIPE_DIRECTORY_NODES_OUT:?}" | awk -F/ '{print $NF}' | fzf)
--             if [ -d "$PTH" ]; then
--               echo ChangeDirectory: "'"${PWD:?}/${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
--             elif [ -f "$PTH" ]; then
--               echo FocusPath: "'"${PWD:?}/${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
--             fi
--             ]===]
--           }, "PopMode"
--         }
--       }
--     },
--     default = {messages = {"PopMode"}}
--   }
-- }
--
-- -- MODES: paste.rs
-- cmodes["paste.rs"] = {
--   name = "paste.rs",
--   key_bindings = {
--     on_key = {
--       p = {
--         help = "paste",
--         messages = {
--           {
--             BashExec = [[
--             PTH=$(basename "${XPLR_FOCUS_PATH:?}")
--             DEST="${XPLR_SESSION_PATH:?}/paste.rs.list"
--             curl --data-binary "@${PTH:?}" "https://paste.rs" | tee -a "${DEST:?}"
--             echo
--             read -p "[enter to continue]"]]
--           }, "PopMode"
--         }
--       },
--       l = {
--         help = "list",
--         messages = {
--           {
--             BashExec = [[
--             cat "${XPLR_SESSION_PATH:?}/paste.rs.list"
--             echo
--             read -p "[enter to continue]"]]
--           }, "PopMode"
--         }
--       },
--       o = {
--         help = "search and open",
--         messages = {
--           {
--             BashExec = [[
--             DEST="${XPLR_SESSION_PATH:?}/paste.rs.list"
--             URL=$(fzf --preview "curl -s '{}'" < "${DEST:?}")
--             if [ "$URL" ]; then
--               OPENER=$(which xdg-open)
--               ${OPENER:-open} "${URL:?}"
--             fi]]
--           }, "PopMode"
--         }
--       },
--       d = {
--         help = "search and delete",
--         messages = {
--           {
--             BashExec = [[
--             DEST="${XPLR_SESSION_PATH:?}/paste.rs.list"
--             URL=$(fzf --preview "curl -s '{}'" < "${DEST:?}")
--             if [ "$URL" ]; then
--               curl -X DELETE "${URL:?}"
--               sd "${URL:?}n" "" "${DEST:?}"
--               echo
--               read -p "[enter to continue]"
--             fi]]
--           }, "PopMode"
--         }
--       },
--       esc = {help = "cancel", messages = {"PopMode"}}
--     }
--   }
-- }
--
-- cmodes["copy"] = {
--   name = "copy",
--   key_bindings = {
--     on_key = {
--       y = {
--         help = "copy focused file",
--         messages = {
--           {
--             BashExecSilently = [[xclip-copyfile $(cat "${XPLR_PIPE_RESULT_OUT:?}")]]
--           }, "PopMode"
--         }
--       },
--       esc = {help = "cancel", messages = {"PopMode"}}
--     }
--   }
-- }
--
-- cmodes["bookmark"] = {
--   name = "bookmark",
--   key_bindings = {
--     on_key = {
--       m = {
--         help = "bookmark dir",
--         messages = {
--           {
--             BashExecSilently = [[
--           PTH="${XPLR_FOCUS_PATH:?}"
--           if [ -d "${PTH}" ]; then
--             PTH="${PTH}"
--           elif [ -f "${PTH}" ]; then
--             PTH="$(dirname "${PTH}")"
--           fi
--           if echo "${PTH:?}" >> "${XPLR_BOOKMARK_FILE:?}"; then
--             echo "LogSuccess: ${PTH:?} added to bookmarks" >> "${XPLR_PIPE_MSG_IN:?}"
--           else
--             echo "LogError: Failed to bookmark ${PTH:?}" >> "${XPLR_PIPE_MSG_IN:?}"
--           fi
--         ]]
--           }
--         }
--       },
--       g = {
--         help = "go to bookmark",
--         messages = {
--           {
--             BashExec = [===[
--             PTH=$(cat "${XPLR_BOOKMARK_FILE:?}" | fzf --no-sort)
--             if [ "$PTH" ]; then
--               echo FocusPath: "'"${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
--             fi
--             ]===]
--           }
--         }
--       },
--       d = {
--         help = "delete bookmark",
--         messages = {
--           {
--             BashExec = [[
--           PTH=$(cat "${XPLR_BOOKMARK_FILE:?}" | fzf --no-sort)
--           sd "$PTH\n" "" "${XPLR_BOOKMARK_FILE:?}"
--         ]]
--           }
--         }
--       },
--       esc = {help = "cancel", messages = {"PopMode"}}
--     }
--   }
-- }
--
-- cmodes["f2"] = {
--   name = "f2",
--   key_bindings = {
--     on_key = {
--       u = {
--         help = "dry run undo",
--         messages = {
--           {
--             BashExec = [[
--             f2 -u
--             read -p "[press enter to continue]"]]
--           }, "PopMode"
--         }
--       },
--       U = {
--         help = "undo",
--         messages = {
--           {
--             BashExecSilently = [[
--             f2 -u -x
--             ]]
--           }, "ExplorePwdAsync"
--         }
--       },
--       b = {
--         help = "dry run org books",
--         messages = {
--           {
--             BashExec = [[
--             f2 -F -r '{{xt.Title}} by {{xt.Creator}}{{ext}}'
--             read -p '[press enter to continue]'
--             ]]
--           }
--         }
--       },
--       B = {
--         help = "org books",
--         messages = {
--           {
--             BashExecSilently = [[
--             f2 -F -r '{{xt.Title}} by {{xt.Creator}}{{ext}}' -x
--             ]]
--           }, "ExplorePwdAsync"
--         }
--       },
--       m = {
--         help = "dry run org music",
--         messages = {
--           {
--             BashExec = [[
--           f2 -F -f '(\d+).*' -r '{{id3.artist}}/{{id3.album}}/$1-{{id3.title}}{{ext}}'
--               read -p '[press enter to continue]
--             ]]
--           }
--         }
--       },
--       M = {
--         help = "org music",
--         messages = {
--           {
--             BashExecSilently = [[
--             f2 -F -f '(\d+).*' -r '{{id3.artist}}/{{id3.album}}/$1-{{id3.title}}{{ext}}' -x
--             ]]
--           }, "ExplorePwdAsync"
--         }
--       },
--       i = {
--         help = "dry run org images",
--         messages = {
--           {
--             BashExec = [[
--             f2 -F -r '{{x.dt.YYYY}}/{{x.dt.MMM}}-{{x.dt.DD}}-{{x.dt.YYYY}}_{{x.dt.H}}-{{x.dt.mm}}-{{x.dt.ss}}_{{x.make}}-{{x.model}}{{ext}}'
--             read -p '[press enter to continue]'
--             ]]
--           }
--         }
--       },
--       I = {
--         help = "org images",
--         messages = {
--           {
--             BashExecSilently = [[
--             f2 -F -r '{{x.dt.YYYY}}/{{x.dt.MMM}}-{{x.dt.DD}}-{{x.dt.YYYY}}_{{x.dt.H}}-{{x.dt.mm}}-{{x.dt.ss}}_{{x.make}}-{{x.model}}{{ext}}' -x
--             ]]
--           }, "ExplorePwdAsync"
--         }
--       },
--       esc = {help = "cancel", messages = {"PopMode"}}
--     }
--   }
-- }

-- }}} === custom mode ===

-- vim: ft=lua:et:sw=0:ts=2:sts=2:fdm=marker:fmr={{{,}}}:
