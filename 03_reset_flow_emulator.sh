#!/bin/bash

echo "Resetting this emulator..."
echo "Deleting mongo db backup..."

$(rm -rf flowdb/)

echo "Done"
echo "Removing Private key files..."

$(rm -rf account*.pkey)

echo "Done"
echo "Recovering flow.json from backup..."

$(cat flow.json_bck > flow.json)

echo "Done. FLow emulator was reset successfully!"
exit 1

# TESTING CRAP (REMOVE THE exit 1 TO ACTIVATE THESE BLOCKS)
GITIGNORE=$(cat .gitignore)

GIT_ELEMENTS=$(echo $GITIGNORE | awk '
    {
        for(i=1; i<NF; i++) {
            print $i;
        }
    }
' RS="" FS=" " OFS=" ")

ELEMENT="account09.pkey"

if [[ $GIT_ELEMENTS == *"$ELEMENT"* ]];
then
    echo "Found at least one instance of "$ELEMENT
else
    echo "Found NO instances of "$ELEMENT
fi

exit 1
FLOW_ACCOUNTS=$(cat flow.json | jq '.')

for i in {1..4}
do
    ADDRESS="0x0000000"$i
    echo $ADDRESS

    NAME="test_account0"$i
    echo $NAME

    LOCATION="test_account0"$i".pkey"
    echo $LOCATION

    JSON_ACCOUNT="{\"$NAME\": { \"address\": \"$ADDRESS\", \"key\": { \"type\": \"file\", \"location\": \"$LOCATION\" }}}"

    # echo $JSON_ACCOUNT | jq '.'

    FLOW_ACCOUNTS=$(echo $FLOW_ACCOUNTS | jq --argjson new_account "$JSON_ACCOUNT" '.accounts += $new_account')

    # echo $FLOW_ACCOUNTS | jq '.'

    i=$i+1
done

echo $FLOW_ACCOUNTS | jq '.' > new_flow.json

echo "DONE!"

# NEW_VAR=$(echo $FLOW_ACCOUNTS | jq --arg address "$ADDRESS" --arg name "$NAME" --arg location "$LOCATION" '.accounts += { ($name|toString): { "address": $address, "key": { "type": "file", "location": $location}}}')

# echo $NEW_VAR | jq '.'

# echo $FLOW_ACCOUNTS | jq '.'

# ACCOUNT_NAME="SomeName"
# ACCOUNT_ADDRESS="SomeAddress"
# ACCOUNT_FILENAME="SomeLocation"

# JSON_ACCOUNT="{\"$ACCOUNT_NAME\": { \"address\": \"$ACCOUNT_ADDRESS\", \"key\": { \"type\": \"file\", \"location\": \"$ACCOUNT_FILENAME\" }}}"

# echo $JSON_ACCOUNT | jq '.'

# FLOW_ACCOUNTS=$(echo $FLOW_ACCOUNTS | jq --argjson new_account "$JSON_ACCOUNT" '.accounts += $new_account')

# echo $FLOW_ACCOUNTS | jq '.'

# exit 1