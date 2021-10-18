# tomb --
{:data-section="shell"}
{:data-date="March 25, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Encrypted dmg

## OPTIONS

`bash mactomb.sh create -f ~/mactomb -s 100m`
: Creates a 100MB mactomb size

`bash mactomb.sh create -f ~/mactomb -s 100m -p ~/secret_files/`
: Creates a 100MB mactomb size and then copies file(s) inside

`bash mactomb.sh app -f ~/mactomb.dmg -a '/Applications/Firefox.app/Contents/MacOS/firefox-bin -p secretprofile' -b ~/hook.sh`
: Creates the bash file 'hook.sh' that will call Firefox with the profile \n 'secretprofile' after 'mactomb.dmg' mouting (to be done through the script and not Finder)
b

`bash mactomb.sh forge -b ~/hook.sh -o ~/mynewapp`
: Creates the Automator App called 'mynewapp' that will call 'hook.sh' on opening

`bash mactomb.sh forge -f ~/mactomb -s 100m -a "/Applications/Firefox.app/Content/MacOS/firefox-bin -p secretprofile" -b ~/hook.sh -o ~/mynewapp`
: forge does all 3
