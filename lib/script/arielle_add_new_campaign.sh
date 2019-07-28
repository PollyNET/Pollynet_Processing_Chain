#!/bin/bash
# This script will help the user to add entry for the current PollyXT campagin.
#!/bin/bash
# This script will help to process the current polly data with using Pollynet processing chain

#########################
# The command line help #
#########################
display_help() {
    echo "Usage: $0 [option...]" >&2
    echo 
    echo -e "Hello, dear OCEANET crew!\nThis script will guide you to add a new campaign entry for the Pollynet Processing Chain. Let's get started."

    echo -e "\n\n\nPlease follow the example below to finish the description about your current campaign.\nAfter you finish it, you can check the info in $CAMP_HISTORY_FILE.\nPlease make sure the format is correct, otherwise the processing program would fail.\n\n"
    echo "   -h, --help              show help message"
    echo
    # echo some stuff here for the -a or --add-options 
    exit 1
}

# parameter initialization
CAMP_HISTORY_FILE="/home/picasso/todo_filelist/pollynet_history_of_places_new.txt"

################################
# Check if parameters options  #
# are given on the commandline #
################################
while :
do
    case "$1" in
  
      -h | --help)
          display_help  # Call your function
          exit 0
          ;;

      --) # End of all options
          shift
          break
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          ## or call function display_help
          exit 1 
          ;;
      *)  # No more options
          break
          ;;
    esac
done

/bin/nano $CAMP_HISTORY_FILE