
# ani-cli-batch function wrapper
ani-cli-batch() {
    # Variables
    local BASHLOCATION=$(which bash)
    local command="ani-cli -d"

    # Functions
    
    # Display a menu
    function showmenufor() {
        echo "Choose an option by selecting it's S.no:"
        local i=1
        local j=1
        for option in "$@"; do
            if [[ $j -eq 1 ]]; then
                let "j++"
            else
                echo"";
                echo -n "   $i."; echo "$option"
                echo;
                let "i++"
            fi
        done
        read -n 1 choice
        echo ""
        local a=1
        local b=1
        for option in "$@"; do
            if [[ $b -eq 1 ]]; then
                let "b++"
            else
                if [[ $a -eq $choice ]]; then
                    firstarg=$1
                    eval "$(echo "$firstarg")=$option"
                    break
                else
                    let "a++"
                fi
            fi
        done
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

    while [ $addanime == true ]; do
        echo "What do you want to download?"
        read animename

        echo
        echo "Running ani-cli's search operation"
        echo "Exit after finding the correct S.no and episode range"
        echo ""
        ani-cli -d $animename
        echo ""

        echo "What number on the list was your anime?"
        read selection

        command=$(echo $command $animename -S $selection)

        echo
        echo "What range of episodes do you want to download? (startep-endep)(eg:- 1-17)"
        read range

        command=$(echo $command -r $range)

        echo
        echo "Do you want to specify a download quality (default is 1080p)? (y/n)"
        echo "(ani-cli will default to the highest quality if specified video quality is not found)"
        read -n 1 qualitychoice

        if [ $qualitychoice == y ]; then
            echo
            echo
            showmenufor quality 240p 360p 480p 720p
            command=$(echo $command -q $quality)
        else 
            echo
        fi

        until [ $validchoice == true ]; do
            clear
            echo "What do you want to do?"
            echo "1.Add more anime (add)"
            echo "2.Start Downloading (download)"
            echo "3.Print the download command (print)"
            echo "4.Cancel and quit (cancel)"
            read instruction

            case $instruction in
                1|add)
                    command=$(echo $command "; ani-cli -d" )
                    addanime=true
                    validchoice=true
                    ;;
                2|download)
                    PATH=$PATH "$BASHLOCATION" -c "$command"
                    if [ $? == 0 ]; then
                        echo "Download Successful"
                        addanime=false
                    else
                        echo "Download failed! Printing the download command."
                        echo $command
                        addanime=false
                    fi
                    validchoice=true
                    ;;
                3|print)
                    clear && echo "Printing the download command."
                    echo
                    echo $command
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