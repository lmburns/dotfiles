local function setup(args)
  local xplr = xplr

  if args == nil then
    args = {}
  end

  if args.mode == nil then
    args.mode = "default"
  end

  if args.key == nil then
    args.key = "Z"
  end

  xplr.config.modes.builtin[args.mode].key_bindings.on_key[args.key] = {
    help = "zoxide jump",
    messages = {
      {
        BashExec = [===[
        PTH=$(zoxide query -i)
        if [ -d "$PTH" ]; then
          echo ChangeDirectory: "'"${PTH:?}"'" >> "${XPLR_PIPE_MSG_IN:?}"
        fi
        ]===]
      },
      "PopMode",
    }
  }
end

return { setup = setup }
