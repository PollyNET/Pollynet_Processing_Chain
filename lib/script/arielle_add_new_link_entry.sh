#!/bin/bash
# This script will help the user to add entry for the current PollyXT campagin.

CAMP_HISTORY_FILE="/home/picasso/Pollynet_Processing_Chain/config/pollynet_processing_config_history.txt"

example_entry="arielle,2019-02-07 00:00:00,2021-1-1 00:00:00,arielle_config_20190722.json,pollynet_processing_chain_arielle.m,Move to Leipzig,arielle_read_defaults.m"
new_campaign_entry=""

promptInput(){
    echo -e "Hello, dear OCEANET crew!\nThis script will guide you to add a new link entry for the Pollynet Processing Chain to help search the corresponding polly processing module. Let's get started."

    echo -e "\n\n\nPlease follow the example below to finish the description about your current campaign.\nAfter you finish it, you can check the info in $CAMP_HISTORY_FILE.\nPlease make sure the format is correct, otherwise the processing program would fail.\n\n"
	
	echo -e "name,start time,end time,config file,processing function, update Info(as short as possible, and not use comma),load defaults function"
	echo -e $example_entry '\n'

    echo -n "Enter the link entry and press [ENTER]: "
    read new_campaign_entry

    # confirm the entry
	echo
	echo
	echo
	echo "Your input link entry is: "
    echo $new_campaign_entry

    echo 
    echo
    echo "Do you confirm the info? [yes|no] and press [ENTER]: "
    read flag_confirm
	
	if [[ "$flag_confirm" = "yes" ]]; then
		echo 
	else
		promptInput
	fi
}

promptInput

echo "Writing the link entry to the history link file..."
echo $new_campaign_entry >> $CAMP_HISTORY_FILE
echo "Done!"
echo -e "You can go to check it!\n$CAMP_HISTORY_FILE"
