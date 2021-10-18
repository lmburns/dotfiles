# signals --
{:data-section="shell"}
{:data-date="May 30, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS
Signals and what they mean

## SIGNALS

`SIGHUP`
: If a process is being run from  terminal and that terminal suddenly goesaway then the process receives this signal. “HUP” is short for “hang up”and refers to hanging up the telephone in the days of telephone modems.

`SIGINT`
: The process was “interrupted”. This happens when you press Control+C onthe controlling terminal.

`SIGQUIT - SIGILL`
: Illegal instruction. The program contained some machine code the CPUcan't understand.

`SIGTRAP`
: This signal is used mainly from within debuggers and program tracers.

`SIGABRT`
: The program called the abort() function. This is an emergency stop.

`SIGBUS`
: An attempt was made to access memory incorrectly. This can be caused byalignment errors in memory access etc.

`SIGFPE`
: A floating point exception happened in the program.

`SIGKILL`
; The process was explicitly killed by somebody wielding the killprogram.

`SIGUSR1`
: Left for the programmers to do whatever they want.

`SIGSEGV`
: An attempt was made to access memory not allocated to the process. Thisis often caused by reading off the end of arrays etc.

`SIGUSR2`
: Left for the programmers to do whatever they want.

`SIGPIPE`
: If a process is producing output that is being fed into another process thatconsume it via a pipe (“producer | consumer”) and the consumerdies then the producer is sent this signal.

`SIGALRM`
: A process can request a “wake up call” from the operating system at sometime in the future by calling the alarm() function. When that time comesround the wake up call consists of this signal.

`SIGTERM`
: The process was explicitly killed by somebody wielding the killprogram.

`SIGCHLD`
: The process had previously created one or more child processes with thefork() function. One or more of these processes has since died.

`SIGCONT`
: (To be read in conjunction with SIGSTOP.)If a process has been paused by sending it SIGSTOP then sending *SIGCONT* to the process wakes it up again (“continues” it).

`SIGSTOP`
: (To be read in conjunction with SIGCONT.)If a process is sent SIGSTOP it is paused by the operating system. All its
No.Short nameWhat it meansstate is preserved ready for it to be restarted (by SIGCONT) but it doesn'tget any more CPU cycles until then.

`SIGTSTP`
: Essentially the same as SIGSTOP. This is the signal sent when the user hitsControl+Z on the terminal. (SIGTSTP is short for “terminal stop”) Theonly difference between SIGTSTP and SIGSTOP is that pausing is only the default action for SIGTSTP but is the required action forSIGSTOP. The process can opt to handle SIGTSTP differently but gets nochoice regarding SIGSTOP.

`SIGTTIN`
: The operating system sends this signal to a backgrounded process when ittries to read input from its terminal. The typical response is to pause (as perSIGSTOP and SIFTSTP) and wait for the SIGCONT that arrives when theprocess is brought back to the foreground.

`SIGTTOU`
: The operating system sends this signal to a backgrounded process when ittries to write output to its terminal. The typical response is as perSIGTTIN.

`SIGURG`
: The operating system sends this signal to a process using a networkconnection when “urgent” out of band data is sent to it.

`SIGXCPU`
: The operating system sends this signal to a process that has exceeded itsCPU limit. You can cancel any CPU limit with the shell command“ulimit-tunlimited” prior to running make though it is morelikely that something has gone wrong if you reach the CPU limit in make.

`SIGXFSZ`
: The operating system sends this signal to a process that has tried to create afile above the file size limit. You can cancel any file size limit with theshell command “ulimit-funlimited” prior to running make though it ismore likely that something has gone wrong if you reach the file size limitin make.

`SIGVTALRM`
: This is very similar to SIGALRM, but while SIGALRM is sent after acertain amount of real time has passed, SIGVTALRM is sent after a certainamount of time has been spent running the process.

`SIGPROF`
: This is also very similar to SIGALRM and SIGVTALRM, but whileSIGALRM is sent after a certain amount of real time has passed, SIGPROFis sent after a certain amount of time has been spent running the processand running system code on behalf of the process.

`SIGWINCH`
: (Mostly unused these days.) A process used to be sent this signal when oneof its windows was resized.

`SIGIO`
: (Also known as SIGPOLL.) A process can arrange to have this signal sentto it when there is some input ready for it to process or an output channelhas become ready for writing.

`SIGPWR`
: A signal sent to processes by a power management service to indicate thatpower has switched to a short term emergency power supply. The process(especially long-running daemons) may care to shut down cleanlt beforethe emergency power fails.
