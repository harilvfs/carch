# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_carch_global_optspecs
	string join \n l/log v/version c/catppuccin-mocha d/dracula g/gruvbox n/nord r/rose-pine h/help
end

function __fish_carch_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_carch_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_carch_using_subcommand
	set -l cmd (__fish_carch_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c carch -n "__fish_carch_needs_command" -s l -l log -d 'Enable logging, output is on ~/.config/carch/carch.log'
complete -c carch -n "__fish_carch_needs_command" -s v -l version -d 'Print version information'
complete -c carch -n "__fish_carch_needs_command" -s c -l catppuccin-mocha -d 'Set theme to Catppuccin Mocha'
complete -c carch -n "__fish_carch_needs_command" -s d -l dracula -d 'Set theme to Dracula'
complete -c carch -n "__fish_carch_needs_command" -s g -l gruvbox -d 'Set theme to Gruvbox'
complete -c carch -n "__fish_carch_needs_command" -s n -l nord -d 'Set theme to Nord'
complete -c carch -n "__fish_carch_needs_command" -s r -l rose-pine -d 'Set theme to Rosé Pine'
complete -c carch -n "__fish_carch_needs_command" -s h -l help -d 'Print help'
complete -c carch -n "__fish_carch_needs_command" -f -a "check-update" -d 'Check for updates'
complete -c carch -n "__fish_carch_needs_command" -f -a "update" -d 'Update the application'
complete -c carch -n "__fish_carch_needs_command" -f -a "uninstall" -d 'Uninstall the application'
complete -c carch -n "__fish_carch_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s l -l log -d 'Enable logging, output is on ~/.config/carch/carch.log'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s c -l catppuccin-mocha -d 'Set theme to Catppuccin Mocha'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s d -l dracula -d 'Set theme to Dracula'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s g -l gruvbox -d 'Set theme to Gruvbox'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s n -l nord -d 'Set theme to Nord'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s r -l rose-pine -d 'Set theme to Rosé Pine'
complete -c carch -n "__fish_carch_using_subcommand check-update" -s h -l help -d 'Print help'
complete -c carch -n "__fish_carch_using_subcommand update" -s l -l log -d 'Enable logging, output is on ~/.config/carch/carch.log'
complete -c carch -n "__fish_carch_using_subcommand update" -s c -l catppuccin-mocha -d 'Set theme to Catppuccin Mocha'
complete -c carch -n "__fish_carch_using_subcommand update" -s d -l dracula -d 'Set theme to Dracula'
complete -c carch -n "__fish_carch_using_subcommand update" -s g -l gruvbox -d 'Set theme to Gruvbox'
complete -c carch -n "__fish_carch_using_subcommand update" -s n -l nord -d 'Set theme to Nord'
complete -c carch -n "__fish_carch_using_subcommand update" -s r -l rose-pine -d 'Set theme to Rosé Pine'
complete -c carch -n "__fish_carch_using_subcommand update" -s h -l help -d 'Print help'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s l -l log -d 'Enable logging, output is on ~/.config/carch/carch.log'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s c -l catppuccin-mocha -d 'Set theme to Catppuccin Mocha'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s d -l dracula -d 'Set theme to Dracula'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s g -l gruvbox -d 'Set theme to Gruvbox'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s n -l nord -d 'Set theme to Nord'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s r -l rose-pine -d 'Set theme to Rosé Pine'
complete -c carch -n "__fish_carch_using_subcommand uninstall" -s h -l help -d 'Print help'
complete -c carch -n "__fish_carch_using_subcommand help; and not __fish_seen_subcommand_from check-update update uninstall help" -f -a "check-update" -d 'Check for updates'
complete -c carch -n "__fish_carch_using_subcommand help; and not __fish_seen_subcommand_from check-update update uninstall help" -f -a "update" -d 'Update the application'
complete -c carch -n "__fish_carch_using_subcommand help; and not __fish_seen_subcommand_from check-update update uninstall help" -f -a "uninstall" -d 'Uninstall the application'
complete -c carch -n "__fish_carch_using_subcommand help; and not __fish_seen_subcommand_from check-update update uninstall help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
