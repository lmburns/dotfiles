local function setup()
  local xplr = xplr

  xplr.config.modes.builtin.default.key_bindings.on_key["}"] = {
    help = "}",
    messages = {
      {
        BashExecSilently = [===[
        N=$(($(tput lines)/3))
        echo FocusNextByRelativeIndex: $N >> ${XPLR_PIPE_MSG_IN:?}
        ]===]
      }
    }
  }

  xplr.config.modes.builtin.default.key_bindings.on_key["{"] = {
    help = "{",
    messages = {
      {
        BashExecSilently = [===[
        N=$(($(tput lines)/3))
        echo FocusPreviousByRelativeIndex: $N >> ${XPLR_PIPE_MSG_IN:?}
        ]===]
      }
    }
  }
end

return {setup = setup}
