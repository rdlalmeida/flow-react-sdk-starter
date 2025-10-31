#!/bin/bash

# Run a simple routine to read all the contents of a .env file into memory, i.e., setup all variables set in this
# file as global ones first

# Test if the .env file exists first
if [ ! -f .env ];
then
    echo "Unable to find any .env file. Cannot continue!";
    exit 1
else
    while read -r LINE;
    do
        if [[ $LINE == *'='* ]] && [[ $LINE != '#'* ]]; then
            ENV_VAR="$(echo $LINE | envsubst)"
            eval "declare ${ENV_VAR}"
        fi
    done < .env
fi

# Use this section to test if the environmental variables set through the .env file
# were properly read and set
# echo "DB_PATH = ${DB_PATH}"
# echo "FLOW_JSON = ${FLOW_JSON}"
#
# echo "MONGO_INITDB_DATABASE = ${MONGO_INITDB_DATABASE}"
# echo "MONGO_INITDB_USERNAME = ${MONGO_INITDB_USERNAME}"
# echo "MONGO_INITDB_PASSWORD = ${MONGO_INITDB_PASSWORD}"
# echo "MONGO_DB_LOG = ${DB_LOG}"
# echo "Composed path: ${DB_PATH}/db_log.txt"
# exit 1

# Test if the MongoDB service is online and running. Start it if its not the case
# eval $(systemctl is-active --quiet mongod && echo "mongod service is up and running. Nothing else to do" || systemctl start mongod)

service_status=$(systemctl is-active mongod)
echo "Service status = ${service_status}"

if [[ "$service_status" = "failed" ]] || [[ "$service_status" = "inactive" ]];
then
    echo "DB service is down. Starting it..."
    systemctl start mongod

    # I'm having a shit ton of problems while starting the db service if down. After loads of trial and error
    # it seems that the best option is to simply wait a second before starting the service and running the
    # rest of the script. This maybe due to the fact that the service takes a while to be up (but no more than 1s)
    # and when I start sending commands to the DB without a service to deal with it, it breaks
    sleep 1s

    # Verify that the damn service is indeed active
    service_status=$(systemctl is-active mongod)

    if [ "$service_status" = "active" ];
    then
        echo "Success! The mongod service is now ${service_status}"
    else
        echo "Unable to start the mongod service. Cannot continue..."
    fi
else
    echo "mongod service is up and running. Nothing else to do!"
fi

# Validate if the database credentials were properly loaded to memory and, if so, start the Mongo database
if test -z "$MONGO_INITDB_DATABASE";
then
    echo "Mongo database name was not set yet! Cannot continue!"
    exit 1
fi

if test -z "$MONGO_INITDB_USERNAME";
then
    echo "Mongo database username was not set yet! Cannot continue!"
    exit 1
fi

if test -z "$MONGO_INITDB_PASSWORD";
then
    echo "Mongo database password was not set yet! Cannot continue!"
    exit 1
fi

# Test and create the database directory if it does not exists
if test -z "$DB_PATH";
then
    echo "Database directory path was not set yet. Cannot continue!"
    exit 1
elif [ ! -d "$DB_PATH" ];
then
    mkdir $DB_PATH
    echo "Created a new database directory at '${DB_PATH}'"
fi

# Same for the log file
if test -z "$DB_LOG";
then
    echo "Log path was not defined yet. Cannot continue!"
    exit 1
elif [ ! -f "$DB_LOG" ];
then
    touch "$DB_LOG"
    echo "Log file created in ${DB_LOG}"
fi

# All good it seems. Continue building the command to start the database
# NOTE: If, when starting this database, you get a 'Error: couldn't connect to server 127.0.0.1:27017' error,
# fix it by doing:
#
# 1. Stop the mongod service
#   $ sudo systemctl stop mongod
#
# 2. Remove the .lock file that is creating the problem
#   $ sudo rm /var/lib/mongodb/mongod.lock
#
# 3. Repair the mongod service
#   $ mongod --repair
#
# 4. Restart the mongod service
#   $ sudo systemctl start mongod
#
# 5. Verify that the service is Active and Running
#   $ sudo systemctl status mongod
#
# 6. Run this script again
mongosh "${MONGO_INITDB_DATABASE}" --quiet > /dev/null <<EOF
    // Set the credentials to use
    var rootUser = '${MONGO_INITDB_USERNAME}';
    var rootPassword = '${MONGO_INITDB_PASSWORD}';
    var emulatorDatabase = '${MONGO_INITDB_DATABASE}';

    // Set the success response (JSON object) to a dedicated variable for later comparisson
    var successResponse = { ok:1 };

    // Try to authenticate into the provided database with the credentials provided, saving the returned response into a variable
    var response = db.auth(rootUser, rootPassword);

    // Grab a database instance
    db = db.getSiblingDB(emulatorDatabase);

    // Check if a success response was returned when attempted to login into the database. If so, inform
    // the user, otherwise proceed to create the user, password and login into them
    if (JSON.stringify(response) == JSON.stringify(successResponse)) {
        // User login successful. Nothing more to do. Log the operation and move on
        console.log(
            "Login successful with user '"
            .concat("${MONGO_INITDB_USERNAME}")
            .concat("' into database '")
            .concat("${MONGO_INITDB_DATABASE}")
            .concat("'")
            );
    } else {
        // The user doesn't exists yet. Create it
        db.createUser({
            user: rootUser,
            pwd: rootPassword,
            roles: [{ role: "readWrite", db: emulatorDatabase }],
            mechanisms: [ "SCRAM-SHA-1" ]
        });

        // And login into the newly created credential pair
        let response = db.auth(rootUser, rootPassword)

        // Inform the user
        console.log("User '"
        .concat(${MONGO_INITDB_USERNAME})
        .concat(" in the database '")
        .concat(${MONGO_INITDB_DATABASE})
        .concat("'")
        );

        // Log off from the command line prompt
        quit
    }
EOF

# Check if the .json configuration file already exists and set it to be created if not
if test -z "$FLOW_JSON";
then
    echo "flow.json file path was not yet set. Cannot continue!"
    exit 1
# Test now if the file exists
elif [ ! -f "$FLOW_JSON" ];
then
    # Set the flag to generate the flow.json file
    INIT=true
else
    # Otherwise omit this file creation
    INIT=false
fi

# Define the parameter to start the emulator
PORT="3569"
REST_PORT="8888"
ADMIN_PORT="8080"
VERBOSE=true
LOG_FORMAT="text"
BLOCK_TIME="0ms"
CONTRACTS=false
SERVICE_SIG_ALGO="ECDSA_P256"
SERVICE_HASH_ALGO="SHA3_256"
REST_DEBUG=true
GRPC_DEBUG=true
PERSIST=true
SIMPLE_ADDRESSES=false
CHAIN_ID="emulator"
CONTRACT_REMOVAL=true
COVERAGE_REPORT=true

# Not used this one.. for now
DEBUG_PORT="2345"
TOKEN_SUPPLY="1000000000.0"
TRANSACTION_EXPIRY="10"
STORAGE_LIMIT=true
TRANSACTION_FEES=true
TRANSACTION_MAX_GAS_LIMIT="9999"
SCRIPT_GAS_LIMIT="100000"

# Commenting the next set of flags removes certain parameters that can create problems. Uncomment these at your peril
# STORAGE_PER_FLOW=1
# MIN_ACCOUNT_BALANCE=100000

if test -z "$SERVICE_PRIV_KEY";
then
    echo "The private key for Flow's service account was not yet defined. Cannot continue!"
    exit 1
fi

if test -z "$SERVICE_PUB_KEY";
then
    echo "The public key for Flow's service account was not yet defined. Cannot continue!"
    exit 1
fi

# Create the initialization command for the Flow emulator
command_string="flow emulator start --port=${PORT} --rest-port=${REST_PORT} --admin-port=${ADMIN_PORT} --verbose=${VERBOSE} --log-format=${LOG_FORMAT} --block-time=${BLOCK_TIME} --chain-id=${CHAIN_ID} --contract-removal=${CONTRACT_REMOVAL} --coverage-reporting=${COVERAGE_REPORT} --contracts=${CONTRACTS} --service-sig-algo=${SERVICE_SIG_ALGO} --service-hash-algo=${SERVICE_HASH_ALGO} --init=${INIT} --rest-debug=${REST_DEBUG} --grpc-debug=${GRPC_DEBUG} --persist=${PERSIST} --dbpath=${DB_PATH} --simple-addresses=${SIMPLE_ADDRESSES} --token-supply=${TOKEN_SUPPLY} --transaction-expiry=${TRANSACTION_EXPIRY} --storage-limit=${STORAGE_LIMIT}"

if [ -n "$STORAGE_PER_FLOW" ];
then
    command_string="${command_string} --storage-per-flow=${STORAGE_PER_FLOW}"
fi

if [ -n "$MIN_ACCOUNT_BALANCE" ];
then
    command_string="${command_string} --min-account-balance=${MIN_ACCOUNT_BALANCE}"
fi

command_string="${command_string} --transaction-fees=${TRANSACTION_FEES} --transaction-max-gas-limit=${TRANSACTION_MAX_GAS_LIMIT} --script-gas-limit=${SCRIPT_GAS_LIMIT}"

# Command composition finished. Run it
echo "Running FLOW emulator with\n"
echo "${command_string}\n"

eval $command_string