function __fish_carch_no_subcommand
    for i in (commandline -opc)
        switch $i
            case --help -h --version -v --list-scripts -l --no-preview --log --check-update --update --uninstall
                return 1
        end
    end
    return 0
end

complete -c carch -n '__fish_carch_no_subcommand' -l help -d "Show the help message"
complete -c carch -n '__fish_carch_no_subcommand' -s h -d "Show the help message"
complete -c carch -n '__fish_carch_no_subcommand' -l version -d "Show the program version"
complete -c carch -n '__fish_carch_no_subcommand' -s v -d "Show the program version"
complete -c carch -n '__fish_carch_no_subcommand' -l list-scripts -d "List all available scripts"
complete -c carch -n '__fish_carch_no_subcommand' -s l -d "List all available scripts"
complete -c carch -n '__fish_carch_no_subcommand' -l no-preview -d "Run without displaying script previews in menus"
complete -c carch -n '__fish_carch_no_subcommand' -l log -d "Enable logging for the current session only"
complete -c carch -n '__fish_carch_no_subcommand' -l check-update -d "Check if a new version of Carch is available"
complete -c carch -n '__fish_carch_no_subcommand' -l update -d "Get instructions for updating Carch"
complete -c carch -n '__fish_carch_no_subcommand' -l uninstall -d "Get instructions for uninstalling Carch"

