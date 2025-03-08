function __fish_carch_no_subcommand
    for i in (commandline -opc)
        switch $i
            case --help --version --gen-config --config -c --run-script -r --list-scripts -l --search -s --check-update --update --uninstall
                return 1
        end
    end
    return 0
end

complete -c carch -n '__fish_carch_no_subcommand' -l help -d "Show the help message"
complete -c carch -n '__fish_carch_no_subcommand' -l version -d "Show the program version"
complete -c carch -n '__fish_carch_no_subcommand' -l gen-config -d "Generate a default configuration file"
complete -c carch -n '__fish_carch_no_subcommand' -l config -d "Provide a path to the configuration file" -r
complete -c carch -n '__fish_carch_no_subcommand' -s c -d "Use the default configuration file"
complete -c carch -n '__fish_carch_no_subcommand' -l run-script -d "Run a specific script from the script directory" -r
complete -c carch -n '__fish_carch_no_subcommand' -s r -d "Run a specific script from the script directory" -r
complete -c carch -n '__fish_carch_no_subcommand' -l list-scripts -d "List all available scripts"
complete -c carch -n '__fish_carch_no_subcommand' -s l -d "List all available scripts"
complete -c carch -n '__fish_carch_no_subcommand' -l search -d "Search for scripts by keyword"
complete -c carch -n '__fish_carch_no_subcommand' -s s -d "Search for scripts by keyword"
complete -c carch -n '__fish_carch_no_subcommand' -l check-update -d "Check if a new version of Carch is available"
complete -c carch -n '__fish_carch_no_subcommand' -l update -d "Update Carch using the latest script"
complete -c carch -n '__fish_carch_no_subcommand' -l uninstall -d "Uninstall Carch and remove all associated files"

