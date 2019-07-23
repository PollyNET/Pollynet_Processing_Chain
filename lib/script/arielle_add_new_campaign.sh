#!/bin/bash
# This script will help the user to add entry for the current PollyXT campagin.

CAMP_HISTORY_FILE="/home/picasso/Pollynet_Processing_Chain/todo_filelist/pollynet_history_of_places_new.txt"

example_entry="arielle	Polarstern	20151029	0000	20151030	1515	-27	0	11	3.73E-02	0.0108	, RV Polarstern, Atlantic Ocean"
new_campaign_entry=""

promptInput(){
    echo -e "Hello, dear OCEANET crew!\nThis script will guide you to add a new campaign entry for the Pollynet Processing Chain. Let's get started."

    echo -e "\n\n\nPlease follow the example below to finish the description about your current campaign.\nAfter you finish it, you can check the info in $CAMP_HISTORY_FILE.\nPlease make sure the format is correct, otherwise the processing program would fail.\n\n"
    
	echo -e "Name	Location	Start	Starttime	End	Endtime	Long	Lat	asl	v*	dmol	Caption"
	echo -e $example_entry '\n'

    echo -n "Enter your campaign info and press [ENTER]: "
    read new_campaign_entry

    # confirm the entry
	echo
	echo
	echo
	echo "Your input campaign info is: "
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

echo "Writing the campaign entry to the campaign history file..."
echo $new_campaign_entry >> $CAMP_HISTORY_FILE
echo "Done!"
echo -e "You can go to check it!\n$CAMP_HISTORY_FILE"
