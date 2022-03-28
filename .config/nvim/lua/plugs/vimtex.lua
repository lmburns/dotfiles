local autocmd = require("common.utils").autocmd

g.vimtex_view_method = "zathura"
g.tex_flavor = "latex"
g.vimtex_compiler_latexmk = {
  executable = "latexmk",
  options = {
    "-xelatex",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode",
  },
}

autocmd(
    "vimtex", {
      [[InsertEnter *.tex set conceallevel=0]],
      [[InsertLeave *.tex set conceallevel=2]],
      [[BufEnter *.tex set concealcursor-=n]],
      [[VimLeave *.tex !texclear %]],
    }, true
)
