# https://stackoverflow.com/questions/9112979/pipe-stdout-and-stderr-to-two-different-processes-in-shell-script
# Exit code: https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another
# Executes the command, prints the errors, and save the stdout and stderr as separate files.
save_stdouterr_print_err () {
	commandstr="$1"
	stdoutpath="$2"
	stderrpath="$3"
	if [[ $# -lt 4 ]]
	then
		SSH_EVAL='eval'
	else
		SSH_EVAL="$4"
	fi

	# Steps to bring the exit code of $commandstr after saving output to file.
	# 1. Execute command, and get return code.
	# 2. tee using the stderr
	# 3. write stdout to file without printing
	# 4. exit the command with the exit code.
	#
	# &3 is for temporal use
	# &4 is a return code of the command
	{ { { { eval "$commandstr" 2>&1 1>&3; echo >&4 $?; } | $SSH_EVAL "cat | tee -a '$stderrpath'"; } 3>&1 1>&2; } | $SSH_EVAL "cat >> '$stdoutpath'"; } 4>&1 | { read xs; exit $xs; }
	
	return $?	# Return code of the commandstr

}

# Example
# Notice real-time changes. Rather than waiting until the command finishes, it actually writes on the fly.
# 1. Save locally (a.txt and b.txt)
#save_stdouterr_print_err '{ echo a; sleep 5; echo >&2 b; sleep 5; echo a; sleep 5; echo >&2 b; }' a.txt b.txt 
# 2. Save to ssh server (sv:~/a.txt and sv:~/b.txt)
#save_stdouterr_print_err '{ echo a; sleep 5; echo >&2 b; sleep 5; echo a; sleep 5; echo >&2 b; }' a.txt b.txt 'ssh sv'
