#!/bin/bash

# This script is used to load all accounts configured in a local flow.json into environment variable with the same name (or close to it)
# This simplifies greatly providing the account address as inputs to scripts and transactions, i.e., I want to avoid the annoying copy-paste every time I need to provide one
# NOTE: Because Bash is super picky about allowing subprocesses to define variables in the parent process, I cannot define the variables 'per se' in the script itself. 
# If I run the script 'normally', i.e., using './<script_name>.sh', nothing happens regarding the environment. For that to happen, this script needs to be run with:
#
#   eval "$(./process_accounts.sh)"

# Here's a simple function to determine the type of a variable in bash
typeofvar () {

    local type_signature=$(declare -p "$1" 2>/dev/null)

    if [[ "$type_signature" =~ "declare --" ]]; then
        printf "string"
    elif [[ "$type_signature" =~ "declare -a" ]]; then
        printf "array"
    elif [[ "$type_signature" =~ "declare -A" ]]; then
        printf "map"
    else
        printf "none"
    fi
}

# Read the main JSON object into a variable and extract the 'accounts' to a variable (don't need the rest for now)
accounts=$(cat flow.json | jq '.accounts')

# Split the account names, which are used as the main keys in the accounts element, into a dedicated variable (it's going to be a string)
account_names=$(echo $accounts | jq '. | keys')
# Same thing to extract just the addresses from the bigger element
# account_addresses=$(echo $accounts | jq '.[] | .address')

# Using the typeofvar function, it turns out that both the $account_names and $account_addresses are strings. So I need to convert these to proper bash arrays

# Convert the Python-style array string to a Bash style array
# Remove whitespaces
account_names=${account_names// /}

# Replace ',' with a whitespace
account_names=${account_names//,/ }

# Remove the '[' and ']'
account_names=${account_names##[}
account_names=${account_names%]}

# Remove any double quotes from both array strings before continuing
account_names=$(echo $account_names | tr -d '"')

# The variables are still in string format. I need to change them to proper bash arrays
# Create the empty array first
names=()

# And process each word of the string, i.e., element separated by a white space, as a new array item and add it to the proper structure
for name in $account_names; do
    names+=($name)
done;

name_size=${#names[@]}

for (( i = 0 ; i < $name_size ; i++ )); do
    # printf "Name #%d: %s\\n" $i ${names[$i]}
    acct_address=$(echo $accounts | jq --arg arg1 ${names[$i]} '.[$arg1].address')
    # printf "Name #%d %s: %s\\n" $i ${names[$i]} $acct_address

    # I'm finally at a point where I can export the variables... except... I should have a 'emulator-account' name in the array. The problem is that bash does not likes '-' in variable names, so I need to replace this for a '_' before trying to export the variable
    current_name=${names[$i]}
    
    # Replace any '-' for '_' before trying the export
    current_name=${current_name//-/_}

    # All good. Export the variables
    echo export $current_name=$acct_address
done;