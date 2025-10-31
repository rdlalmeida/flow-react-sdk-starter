#!/bin/bash
# Grab the number of accounts to create from the user input
i=-1
while [ $i -le 0 ]
do
    read -p "How many accounts do you need? " NR_ACCOUNTS

    if ! [[ "$NR_ACCOUNTS" =~ ^[0-9]+$ ]]
    then
        echo "Please insert a valid integer!"
        continue
    fi

    if [ $NR_ACCOUNTS -le 0 ]
    then
        echo "Please provide a positive integer!"
        continue
    fi

    i=$NR_ACCOUNTS
done

echo "Processing " $NR_ACCOUNTS " emulator accounts"

# Read the JSON object from the configuration file to a variable
FLOW_JSON=$(cat flow.json | jq '.')

ACCOUNT_INDEX="00"

for i in $(seq 1 $NR_ACCOUNTS)
do
    echo "Processing Flow Emulator account #" $i
    

    KEYS_OUTPUT=$(flow keys generate)

    # Comment the command above and uncomment the two bellow to go into TEST mode (avoid generating a new key pair per test)
    #echo $KEYS_OUTPUT >> ./keys.txt
    # KEYS_OUTPUT=$(<keys.txt)

    ######################## 0. Set the base element for this exercise at this point
    # Adjust the account index and prefix it with a 0 if the account number is less than 10
    if [ $i -le 9 ]
    then
        ACCOUNT_INDEX="0"$i
    else
        ACCOUNT_INDEX=$i
    fi

    ACCOUNT_NAME="account"$ACCOUNT_INDEX

    ######################## 1. Get a pair of asymmetrical encryption keys into variables
    # NF = Number of Fields
    # FS = Field Separator
    # OFS = Output Field Separator
    # RS = Record Separator
    PRIVATE_KEY=$(echo $KEYS_OUTPUT | awk '
        {
            for (i=2; i<NF; i++) {
                if ($(i-2) == "Private" && $(i-1) == "Key") {
                    print $i;
                    exit;
                }
            }
        }' FS=" " OFS=" "
    )

    PUBLIC_KEY=$(echo $KEYS_OUTPUT | awk '
        {
            for(i=2; i<NF; i++) {
                if($(i-2) == "Public" && $(i-1) == "Key") {
                    print $i;
                    exit;
                }
            }
        }' FS=" " OFS=" "
    )
    echo "Private Key = " $PRIVATE_KEY
    echo "Public Key = " $PUBLIC_KEY

    ######################## 2. Use the Public Key to generate a Flow Emulator account and capture the address to another variable

    ACCOUNT_OUTPUT=$(flow accounts create --key $PUBLIC_KEY)

    ACCOUNT_ADDRESS=$(echo $ACCOUNT_OUTPUT | awk '
        {
            for (i=1; i<NF; i++) {
                if($(i-1) == "Address") {
                    print $i;
                    exit;
                }
            }
        }' FS=" " OFS=" "
    )

    echo "Account address = " $ACCOUNT_ADDRESS

    ######################## 3. Save the Private key to a file and add it to the .gitignore file
    ACCOUNT_FILENAME="./keys/$ACCOUNT_NAME.pkey"

    # Even if a private key file with this name already exists, this command overwrites it. The | tr -d '\n' serves to remove any trailing newlines that can interfere with the emulator
    # reading the key in the file
    echo $PRIVATE_KEY | tr -d '\n' > $ACCOUNT_FILENAME

    # I now need to add the new private key files to my gitignore file. These are just dumb test accounts but it is a good idea to start thinking like a proper cybersecurity analyst
    # To avoid cluttering this file with multiple entries of the same file (which can easily happen if I need to redo this process at some point), I need to increase the complexity a bit here
    # First, read the whole .gitignore into a single String variable. Do this one element at time
    GIT_IGNORE=$(cat .gitignore)

    # NOTE: To be able to extract the .gitignore elements in a format that I can use, I needed to try a bunch of RS, FS and OFS combinations until I found one that worked. Setting RS to nothing and both the FS and OFS to a single space seems to produce what I need
    GIT_ELEMENTS=$(echo $GIT_IGNORE | awk '
        {
            for (i=1; i<NF; i++) {
                print $i;
            }
        }
    ' RS="" FS=" " OFS=" ")

    # Now that I have all the elements I need in a nice String, I can use Bash's String functions to easily determine if the file I'm working on already is there or not
    # NOTE: To be consistent, I also need to do this EVERY CYCLE of this for loop since I'm dynamically updating this file at each loop
    
    # Test if the big .gitignore string already has the file I need to add
    if ! [[ $GIT_ELEMENTS == *"$ACCOUNT_FILENAME"* ]];
    then
        # If I found that it is missing from the big String, append it
        echo $ACCOUNT_FILENAME >> ./.gitignore
        echo "Added "$ACCOUNT_FILENAME" to .gitignore"
    else
        # Otherwise, leave a quick notice and move on
        echo $ACCOUNT_FILENAME" already exists in this .gitignore"
    fi

    ######################## 4. Add the new JSON account element to flow.json

    # Add the new JSON account element to the existing 'accounts' element from flow.json and save it back to the same variable, thus updating it
    # NOTE: This process depends heavily in the 'jq' command, which allows the bash shell to manipulate JSON objects. If needed, install this command with "sudo apt-get install jq"

    # Create the JSON account element in a separate variable given the jq itself is not that good at replacing values in the expression..
    JSON_ACCOUNT="{\"$ACCOUNT_NAME\": { \"address\": \"$ACCOUNT_ADDRESS\", \"key\": { \"type\": \"file\", \"location\": \"$ACCOUNT_FILENAME\" }}}"

    FLOW_JSON=$(echo $FLOW_JSON | jq --argjson new_account "$JSON_ACCOUNT" '.accounts += $new_account')

    echo "Finished configuring " $ACCOUNT_NAME
    
    printf "_____________________________________________________________________________________________\n"
done
# AND ENDS HERE

######################## 5. Save the new JSON object with the new accounts back to the flow.json file
echo "Current FLOW_JSON"
echo $FLOW_JSON | jq '.'


echo $FLOW_JSON | jq '.' > flow.json
