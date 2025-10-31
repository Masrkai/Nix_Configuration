# ani-cli-batch function wrapper
ani-cli-batch() {
    # Variables
    local BASHLOCATION=$(which bash)

    # Function to run ani-cli command with source fallback
    function run_with_source_fallback() {
        local animename="$1"
        local selection="$2"
        local range="$3"
        local quality_spec="$4"

        # If a specific source is requested, try it first
        if [ -n "$quality_spec" ] && [ "$quality_spec" != "0" ]; then
            echo "Trying source $quality_spec: ani-cli -d '$animename' -S $selection -r $range -q $quality_spec"
            if PATH=$PATH "$BASHLOCATION" -c "ani-cli -d '$animename' -S $selection -r $range -q $quality_spec"; then
                return 0
            fi
        fi

        # Try source 1 (first source)
        echo "Trying source 1 (first source): ani-cli -d '$animename' -S $selection -r $range -q 1"
        if PATH=$PATH "$BASHLOCATION" -c "ani-cli -d '$animename' -S $selection -r $range -q 1"; then
            return 0
        fi

        # Try source 2 (second source)
        echo "Trying source 2 (second source): ani-cli -d '$animename' -S $selection -r $range -q 2"
        if PATH=$PATH "$BASHLOCATION" -c "ani-cli -d '$animename' -S $selection -r $range -q 2"; then
            return 0
        fi

        # Try source 3 (third source)
        echo "Trying source 3 (third source): ani-cli -d '$animename' -S $selection -r $range -q 3"
        if PATH=$PATH "$BASHLOCATION" -c "ani-cli -d '$animename' -S $selection -r $range -q 3"; then
            return 0
        fi

        # Finally try without specifying source (let ani-cli choose)
        echo "Trying default (auto-select source): ani-cli -d '$animename' -S $selection -r $range"
        if PATH=$PATH "$BASHLOCATION" -c "ani-cli -d '$animename' -S $selection -r $range"; then
            return 0
        fi

        return 1
    }

    # Main code
    clear
    echo "This is a wrapper for ani-cli that makes it easier to batch download multiple anime"

    # Selecting a download location
    echo
    echo "Please provide a download location or press enter to download into the current directory"
    echo "Please note, I don't check permissions yet!"

    local directory="$(pwd)"
    read directory
    while [ ! -d "$directory" ]; do
        echo "Either I don't know what this is or it's not a directory."
        echo "Please provide a download location:"
        read directory
    done

    if [[ "" == "$directory" ]]; then
        echo "Keeping current directory."
    else
        echo "Changing to $directory."
        cd "$directory"
    fi
    echo

    # Asking for instructions
    local addanime=true
    local validchoice=false
    local download_queue=()

    while [ $addanime == true ]; do
        echo "What do you want to download?"
        read animename

        echo
        echo "Running ani-cli's search operation"
        echo "Exit after finding the correct S.no and episode range"
        echo ""
        ani-cli -d "$animename"
        echo ""

        echo "What number on the list was your anime?"
        read selection

        echo
        echo "What range of episodes do you want to download? (startep-endep)(eg:- 1-17)"
        read range

        echo
        echo "Do you want to specify which source to use? (y/n)"
        echo "(1=first source, 2=second source, etc. Default will try 1→2→3→auto)"
        read -n 1 qualitychoice

        local quality_spec="0"  # 0 means no specific source requested
        if [ $qualitychoice == y ]; then
            echo
            echo "Enter source number (1 for first, 2 for second, etc.):"
            read quality
            quality_spec="$quality"
        else
            echo
        fi

        # Add to download queue
        download_queue+=("$animename|$selection|$range|$quality_spec")

        until [ $validchoice == true ]; do
            clear
            echo "What do you want to do?"
            echo "1.Add more anime (add)"
            echo "2.Start Downloading (download)"
            echo "3.Print the download queue (print)"
            echo "4.Cancel and quit (cancel)"
            read instruction

            case $instruction in
                1|add)
                    addanime=true
                    validchoice=true
                    ;;
                2|download)
                    local all_success=true
                    for anime_info in "${download_queue[@]}"; do
                        IFS='|' read -r animename selection range quality_spec <<< "$anime_info"

                        echo
                        echo "Downloading: $animename (S$selection, range $range)"
                        echo "========================================"

                        if run_with_source_fallback "$animename" "$selection" "$range" "$quality_spec"; then
                            echo "✓ SUCCESS: $animename"
                        else
                            echo "✗ FAILED: $animename"
                            all_success=false
                        fi
                    done

                    if [ $all_success == true ]; then
                        echo
                        echo "🎉 All downloads completed successfully!"
                    else
                        echo
                        echo "⚠️  Some downloads failed."
                    fi
                    addanime=false
                    validchoice=true
                    ;;
                3|print)
                    clear && echo "Current download queue:"
                    echo
                    for anime_info in "${download_queue[@]}"; do
                        IFS='|' read -r animename selection range quality_spec <<< "$anime_info"
                        if [ "$quality_spec" != "0" ]; then
                            echo "• $animename (S$selection, range $range, source $quality_spec)"
                        else
                            echo "• $animename (S$selection, range $range, auto-source)"
                        fi
                    done
                    validchoice=false
                    echo
                    echo "Press any key to continue."
                    read -n 1 whyisdeadpoolsocool
                    ;;
                4|cancel)
                    echo "Cancelling pending operations and quitting."
                    addanime=false
                    validchoice=true
                    ;;
                *)
                    echo "Please make a valid choice!"
                    echo "Valid choices include 1, 2, 3, 4, add, download, print and cancel. Press any key to continue"
                    validchoice=false
                    read -n 1 icannotkeepcomingupwithcoolvariablenamessothisonewillbecalleddattebayo
                    ;;
            esac
        done
        validchoice=false
    done
}