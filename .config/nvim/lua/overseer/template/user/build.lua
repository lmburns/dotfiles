return {
  name = "build",
  builder = function()
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local filep = vim.fn.expand("%:r")
    local cmd

    --       # SAFE
    --       # -fno-strict-aliasing,
    --       # -fno-delete-null-pointer-checks,
    --       # -fwrapv,

    --       # Disable
    --       -Wno-unused,
    --       -Wno-unused-result,
    --       -Wno-unused-variable,
    --       -Wno-gnu-empty-struct,

    if vim.bo.filetype == "go" then
      cmd = {"go", "build", file}
    elseif vim.bo.filetype == "c" then
      cmd = {
        "gcc",
        -- "clang",
        "-std=gnu2x",
        "-g3",
        "-O3",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wfloat-equal",   -- testing floats for equality
        "-Wundef",         -- unitialized identifier evaluated in an #if
        "-Wshadow",        -- variable shadows another
        "-Wpointer-arith", -- anything dpends upon size of func or void
        "-Wcast-align",    -- pointer is cast such that required alignment of target is increased
        "-Wcast-qual",     -- pointer is cast to remove a type qualifier from target type
        "-Wbad-function-cast",
        "-Wold-style-definition",
        "-Wredundant-decls",
        "-Wstrict-aliasing=2",
        "-Wstrict-prototypes", -- func declared/defined without specifying variables
        "-Wstrict-overflow=5",
        "-Wwrite-strings",     -- string constants 'const'
        "-Waggregate-return",  -- funcs that return structs/unions are defined
        "-Wswitch-default",    -- switch statement does not have default
        "-Wswitch-enum",       -- switch statement has index of enum type last a case for an enumeration
        "-Wconversion",        -- implicit conversions that may alter value
        "-Wsign-conversion",
        "-Wunreachable-code",  -- self explanatory
        "-Wnested-externs",
        "-Wdisabled-optimization",
        "-Winline",
        "-Wformat=2",
        "-Winit-self",
        "-Wuninitialized",
        "-Wlogical-op",
        "-Wmissing-prototypes",
        "-Wmissing-declarations",
        "-Wvla",
        "-Wpadded",
        "-Wno-format",
        "-fdata-sections",
        "-ffunction-sections",
        "-fsanitize=address",
        "-fsanitize=undefined",
        "-save-temps",     -- leave behind results of preprocess and assembly
        -- OPTIMIZE
        "-fconserve-stack",
        "-fstack-usage",
        "-o",
        dir .. "/build/" .. filep,
        file,
      }
    elseif vim.bo.filetype == "cpp" then
      cmd = {"clang++", "-std=gnu++2b", "-xc++", "-o", filep, file}
    elseif vim.bo.filetype == "rust" then
      cmd = {"cargo", "build", "--release"}
    end

    return {
      cmd = cmd,
      -- args = {file},
      components = {{"on_output_quickfix", open = true}, "default"},
    }
  end,
  condition = {
    filetype = {"c", "cpp", "go", "rust"},
  },
}
