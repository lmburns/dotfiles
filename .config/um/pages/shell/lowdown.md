# lowdown [input_options] [output_options] [-M metadata] [-m metadata] [-o file] [-T mode] [-X keyword] [file]
{:data-section="shell"}
{:data-date="March 08, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Convert markdown to HTML or PDF.

## OPTIONS
`-s` = standalone mode (plain converts to HTML5)

## EXAMPLES
`lowdown -Tterm README.md | less -R`
: View markdown in terminal window

`lowdown -s -o README.html README.md`
: Straight up HTML5

`lowdown -sTms README.md | groff -itk -mspdf > README.ps`

`lowdown -sTms README.md | pdfroff -itk -mspdf > README.pdf`
: Output PDF
