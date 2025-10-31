import Test
import BlockchainHelpers
import "BallotStandard"
import "ElectionStandard"
import "VoteBoxStandard"
import "VoteBooth"

// EVENTS
// BallotStandard.cdc
access(all) let ballotCreatedEventType: Type = Type<BallotStandard.BallotCreated>()
access(all) let ballotBurnedEventType: Type = Type<BallotStandard.BallotBurned>()

// ElectionStandard.cdc
access(all) let ballotSubmittedEventType: Type = Type<ElectionStandard.BallotSubmitted>()
access(all) let ballotReplacedEventType: Type = Type<ElectionStandard.BallotReplaced>()
access(all) let ballotRevokedEventType: Type = Type<ElectionStandard.BallotRevoked>()
access(all) let ballotsWithdrawnEventType: Type = Type<ElectionStandard.BallotsWithdrawn>()
access(all) let electionCreatedEventType: Type = Type<ElectionStandard.ElectionCreated>()
access(all) let electionDestroyedEventType: Type = Type<ElectionStandard.ElectionDestroyed>()
access(all) let nonNilResourceReturnedEventType: Type = Type<ElectionStandard.NonNilResourceReturned>()

// VoteBoxStandard.cdc
access(all) let voteBoxCreatedEventType: Type = Type<VoteBoxStandard.VoteBoxCreated>()
access(all) let voteBoxDestroyedEventType: Type = Type<VoteBoxStandard.VoteBoxDestroyed>()

// VoteBooth.cdc
access(all) let electionIndexCreatedEventType: Type = Type<VoteBooth.ElectionIndexCreated>()
access(all) let electionIndexDestroyedEventType: Type = Type<VoteBooth.ElectionIndexDestroyed>()
access(all) let voteBoothPrinterAdminCreatedEventType: Type = Type<VoteBooth.VoteBoothPrinterAdminCreated>()
access(all) let voteBoothPrinterAdminDestroyedEventType: Type = Type<VoteBooth.VoteBoothPrinterAdminDestroyed>()

access(all) var eventNumberCount: {Type: Int} = {
    ballotCreatedEventType: 0,
    ballotBurnedEventType: 0,
    ballotSubmittedEventType: 0,
    ballotReplacedEventType: 0,
    ballotsWithdrawnEventType: 0,
    electionCreatedEventType: 0,
    electionDestroyedEventType: 0,
    nonNilResourceReturnedEventType: 0,
    voteBoxCreatedEventType: 0,
    voteBoxDestroyedEventType: 0,
    electionIndexCreatedEventType: 0,
    electionIndexDestroyedEventType: 0,
    voteBoothPrinterAdminCreatedEventType: 0,
    voteBoothPrinterAdminDestroyedEventType: 0
}

access(all) var ballotCreatedEvents: [AnyStruct] = []
access(all) var ballotBurnedEvents: [AnyStruct] = []
access(all) var ballotSubmittedEvents: [AnyStruct] = []
access(all) var ballotReplacedEvents: [AnyStruct] = []
access(all) var ballotsWithdrawnEvents: [AnyStruct] = []
access(all) var electionCreatedEvents: [AnyStruct] = []
access(all) var electionDestroyedEvents: [AnyStruct] = []
access(all) var nonNilResourceReturnedEvents: [AnyStruct] = []
access(all) var voteBoxCreatedEvents: [AnyStruct] = []
access(all) var voteBoxDestroyedEvents: [AnyStruct] = []
access(all) var electionIndexCreatedEvents: [AnyStruct] = []
access(all) var electionIndexDestroyedEvents: [AnyStruct] = []
access(all) var voteBoothPrinterAdminCreatedEvents: [AnyStruct] = []
access(all) var voteBoothPrinterAdminDestroyedEvents: [AnyStruct] = []

access(all) fun validateEvents() {
    ballotCreatedEvents = Test.eventsOfType(ballotCreatedEventType)
    ballotBurnedEvents = Test.eventsOfType(ballotBurnedEventType)
    ballotSubmittedEvents = Test.eventsOfType(ballotSubmittedEventType)
    ballotReplacedEvents = Test.eventsOfType(ballotReplacedEventType)
    ballotsWithdrawnEvents = Test.eventsOfType(ballotsWithdrawnEventType)
    electionCreatedEvents = Test.eventsOfType(electionCreatedEventType)
    electionDestroyedEvents = Test.eventsOfType(electionDestroyedEventType)
    nonNilResourceReturnedEvents = Test.eventsOfType(nonNilResourceReturnedEventType)
    voteBoxCreatedEvents = Test.eventsOfType(voteBoxCreatedEventType)
    voteBoxDestroyedEvents = Test.eventsOfType(voteBoxDestroyedEventType)
    electionIndexCreatedEvents = Test.eventsOfType(electionIndexCreatedEventType)
    electionIndexDestroyedEvents = Test.eventsOfType(electionIndexDestroyedEventType)
    voteBoothPrinterAdminCreatedEvents = Test.eventsOfType(voteBoothPrinterAdminCreatedEventType)
    voteBoothPrinterAdminDestroyedEvents = Test.eventsOfType(voteBoothPrinterAdminDestroyedEventType)

    Test.assert(ballotCreatedEvents.length == eventNumberCount[ballotCreatedEventType]!,
        message: "ERROR: Mismatch between ballotCreatedEvents.length = "
        .concat(ballotCreatedEvents.length.toString())
        .concat(" and eventNumberCount[ballotCreatedEventType] = ")
        .concat(eventNumberCount[ballotCreatedEventType]!.toString())
    )

    Test.assert(ballotBurnedEvents.length == eventNumberCount[ballotBurnedEventType]!,
        message: "ERROR: Mismatch between ballotBurnedEvents.length = "
        .concat(ballotBurnedEvents.length.toString())
        .concat(" and eventNumberCount[ballotBurnedEventType] = ")
        .concat(eventNumberCount[ballotBurnedEventType]!.toString())
    )

    Test.assert(ballotSubmittedEvents.length == eventNumberCount[ballotSubmittedEventType]!,
        message: "ERROR: Mismatch between ballotSubmittedEvents.length = "
        .concat(ballotSubmittedEvents.length.toString())
        .concat(" and eventNumberCount[ballotSubmittedEventType] = ")
        .concat(eventNumberCount[ballotSubmittedEventType]!.toString())
    )

    Test.assert(ballotReplacedEvents.length == eventNumberCount[ballotReplacedEventType]!,
        message: "ERROR: Mismatch between ballotReplacedEvents.length = "
        .concat(ballotReplacedEvents.length.toString())
        .concat(" and eventNumberCount[ballotReplacedEventType] = ")
        .concat(eventNumberCount[ballotReplacedEventType]!.toString())
    )
    
    Test.assert(ballotsWithdrawnEvents.length == eventNumberCount[ballotsWithdrawnEventType]!,
        message: "ERROR: Mismatch between ballotsWithdrawnEvents.length = "
        .concat(ballotsWithdrawnEvents.length.toString())
        .concat(" and eventNumberCount[ballotsWithdrawnEventType] = ")
        .concat(eventNumberCount[ballotsWithdrawnEventType]!.toString())
    )

    Test.assert(electionCreatedEvents.length == eventNumberCount[electionCreatedEventType]!,
        message: "ERROR: Mismatch between electionCreatedEvents.length = "
        .concat(electionCreatedEvents.length.toString())
        .concat(" and eventNumberCount[electionCreatedEventType] = ")
        .concat(eventNumberCount[electionCreatedEventType]!.toString())
    )

    Test.assert(electionDestroyedEvents.length == eventNumberCount[electionDestroyedEventType]!,
        message: "ERROR: Mismatch between electionDestroyedEvents.length = "
        .concat(electionDestroyedEvents.length.toString())
        .concat(" and eventNumberCount[electionDestroyedEventType] = ")
        .concat(eventNumberCount[electionDestroyedEventType]!.toString())
    )
    
    Test.assert(nonNilResourceReturnedEvents.length == eventNumberCount[nonNilResourceReturnedEventType]!,
        message: "ERROR: Mismatch between nonNilResourceReturnedEvents.length = "
        .concat(nonNilResourceReturnedEvents.length.toString())
        .concat(" and eventNumberCount[nonNilResourceReturnedEventType] = ")
        .concat(eventNumberCount[nonNilResourceReturnedEventType]!.toString())
    )
    
    Test.assert(voteBoxCreatedEvents.length == eventNumberCount[voteBoxCreatedEventType]!,
        message: "ERROR: Mismatch between voteBoxCreatedEvents.length = "
        .concat(voteBoxCreatedEvents.length.toString())
        .concat(" and eventNumberCount[voteBoxCreatedEventType] = ")
        .concat(eventNumberCount[voteBoxCreatedEventType]!.toString())
    )

    Test.assert(voteBoxDestroyedEvents.length == eventNumberCount[voteBoxDestroyedEventType]!,
        message: "ERROR: Mismatch between voteBoxDestroyedEvents.length = "
        .concat(voteBoxDestroyedEvents.length.toString())
        .concat(" and eventNumberCount[voteBoxDestroyedEventType] = ")
        .concat(eventNumberCount[voteBoxDestroyedEventType]!.toString())
    )

    Test.assert(electionIndexCreatedEvents.length == eventNumberCount[electionIndexCreatedEventType]!,
        message: "ERROR: Mismatch between electionIndexCreatedEvents.length = "
        .concat(electionIndexCreatedEvents.length.toString())
        .concat(" and eventNumberCount[electionIndexCreatedEventType] = ")
        .concat(eventNumberCount[electionIndexCreatedEventType]!.toString())
    )

    Test.assert(electionIndexDestroyedEvents.length == eventNumberCount[electionIndexDestroyedEventType]!,
        message: "ERROR: Mismatch between electionIndexDestroyedEvents.length = "
        .concat(electionIndexDestroyedEvents.length.toString())
        .concat(" and eventNumberCount[electionIndexDestroyedEventType] = ")
        .concat(eventNumberCount[electionIndexDestroyedEventType]!.toString())
    )

    Test.assert(voteBoothPrinterAdminCreatedEvents.length == eventNumberCount[voteBoothPrinterAdminCreatedEventType]!,
        message: "ERROR: Mismatch between voteBoothPrinterAdminCreatedEvents.length = "
        .concat(voteBoothPrinterAdminCreatedEvents.length.toString())
        .concat(" and eventNumberCount[voteBoothPrinterAdminCreatedEventType] = ")
        .concat(eventNumberCount[voteBoothPrinterAdminCreatedEventType]!.toString())
    )

    Test.assert(voteBoothPrinterAdminDestroyedEvents.length == eventNumberCount[voteBoothPrinterAdminDestroyedEventType]!,
        message: "ERROR: Mismatch between voteBoothPrinterAdminDestroyedEvents.length = "
        .concat(voteBoothPrinterAdminDestroyedEvents.length.toString())
        .concat(" and eventNumberCount[voteBoothPrinterAdminDestroyedEventType] = ")
        .concat(eventNumberCount[voteBoothPrinterAdminDestroyedEventType]!.toString())
    )
}

// TRANSACTIONS
access(all) let createElectionTx: String = "../transactions/01_create_election.cdc"
access(all) let createVoteBoxTx: String = "../transactions/02_create_vote_box.cdc"
access(all) let createBallotTx: String = "../transactions/03_create_ballot.cdc"
access(all) let castBallotTx: String = "../transactions/04_cast_ballot.cdc"
access(all) let submitBallotTx: String = "../transactions/05_submit_ballot.cdc"
access(all) let tallyElectionTx: String = "../transactions/06_tally_election.cdc"
access(all) let destroyElectionTx: String = "../transactions/07_destroy_election.cdc"
access(all) let destroyVoteBoxTx: String = "../transactions/08_destroy_votebox.cdc"
access(all) let cleanupVoteBoothTx: String = "../transactions/09_cleanup_votebooth.cdc"

// SCRIPTS
access(all) let testContractConsistencySc: String = "../scripts/01_test_contract_consistency.cdc"
access(all) let getActiveElectionsSc: String = "../scripts/02_get_active_elections.cdc"
access(all) let getElectionNameSc: String = "../scripts/03_get_election_name.cdc"
access(all) let getElectionBallotSc: String = "../scripts/04_get_election_ballot.cdc"
access(all) let getElectionOptionsSc: String = "../scripts/05_get_election_options.cdc"
access(all) let getElectionIdSc: String = "../scripts/06_get_election_id.cdc"
access(all) let getElectionPublicEncryptionKeySc: String = "../scripts/07_get_public_encryption_key.cdc"
access(all) let getElectionCapabilitySc: String = "../scripts/08_get_election_capability.cdc"
access(all) let getElectionTotalsSc: String = "../scripts/09_get_election_totals.cdc"
access(all) let getElectionStoragePathSc: String = "../scripts/10_get_election_storage_path.cdc"
access(all) let getElectionPublicPathSc: String = "../scripts/11_get_election_public_path.cdc"
access(all) let getElectionsListSc: String = "../scripts/12_get_elections_list.cdc"
access(all) let getBallotOptionSc: String = "../scripts/13_get_ballot_option.cdc"
access(all) let getBallotIdSc: String = "../scripts/14_get_ballot_id.cdc"
access(all) let getElectionResultsSc: String = "../scripts/15_get_election_results.cdc"
access(all) let isElectionFinishedSc: String = "../scripts/16_is_election_finished.cdc"

// PATHS
// VoteBoxStandard.cdc
access(all) let expectedVoteBoxStoragePath: StoragePath = /storage/voteBox
access(all) let expectedVoteBoxPublicPath: PublicPath = /public/voteBox

// VoteBooth.cdc
access(all) let expectedVoteBoothPrinterAdminStoragePath: StoragePath = /storage/VoteBoothPrinterAdmin
access(all) let expectedElectionIndexStoragePath: StoragePath = /storage/ElectionIndex
access(all) let expectedElectionIndexPublicPath: PublicPath = /public/ElectionIndex

// CUSTOM INPUT ARGUMENTS
access(all) let electionNames: [String] = ["A. Bullfights", "B. Coconut Cake", "C. Basketball"]
access(all) let electionBallots: [String] = [
    "A. What should happen to bullfighters once Portugal bans this stupid practice?",
    "B. What is the best frosting for coconut cake?",
    "C. Which NBA team is going to win the 2025-26 championship?"
]
access(all) let electionOptions: [{UInt8: String}] = [
    {
        1: "Starve them to death", 
        2: "Bundle them in a shipping container and drop it into the ocean", 
        3: "Enslave and make them build animal shelters until dead", 
        4: "Process them into animal feed",
        5: "Tax them into poverty and force them to clean animal stalls for food"
    },
    {
        1: "Powdered sugar",
        2: "Shredded coconut",
        3: "Tempered dark chocolate",
        4: "Butter-based frosting",
        5: "Nothing. Leave it as is."
    },
    {
        1: "Minnesota Timber Wolves",
        2: "Oklahoma City Thunder",
        3: "New York Knicks",
        4: "Cleveland Cavaliers",
        5: "None of the above"
    }
]

access(all) let electionPublicEncryptionKeys: [[UInt8]] = [
    [87, 174, 84, 18, 106, 155, 246, 129, 83, 78, 24, 168, 183, 53, 39, 121, 60, 186, 137, 156, 247, 185, 9, 137, 100, 151, 208, 113, 59, 191, 26, 118],
    [51, 171, 190, 97, 148, 77, 139, 219, 238, 108, 187, 103, 11, 17, 101, 98, 82, 99, 198, 155, 229, 236, 199, 71, 83, 213, 183, 240, 193, 220, 78, 239],
    [2, 164, 77, 118, 115, 138, 60, 142, 115, 146, 41, 115, 4, 36, 56, 23, 183, 225, 212, 85, 28, 203, 62, 60, 162, 113, 133, 116, 215, 163, 53, 79]
]

access(all) let electionStoragePaths: [StoragePath] = [
    /storage/Election01,
    /storage/Election02,
    /storage/Election03
]

access(all) let electionPublicPaths: [PublicPath] = [
    /public/Election01,
    /public/Election02,
    /public/Election03
]

// OTHER VARIABLES
access(all) let deployer: Test.TestAccount = Test.getAccount(0x0000000000000007)
access(all) let account01: Test.TestAccount = Test.createAccount()
access(all) let account02: Test.TestAccount = Test.createAccount()
access(all) let account03: Test.TestAccount = Test.createAccount()
access(all) let account04: Test.TestAccount = Test.createAccount()
access(all) let account05: Test.TestAccount = Test.createAccount()

access(all) let accounts: [Test.TestAccount] = [account01, account02, account03, account04, account05]
access(all) let accountAddresses: [Address] = [account01.address, account02.address, account03.address, account04.address, account05.address]

access(all) let verbose: Bool = false

// Simple array to keep the electionIds of the active Election resources
access(all) var activeElectionIds: [UInt64] = []

// And another simple dictionary to store the ballotIds for the Ballots given to the accounts
access(all) var voterBallotIds: {Address: [UInt64]} = {
    account01.address: [],
    account02.address: [],
    account03.address: [],
    account04.address: [],
    account05.address: []
}

// And this one just a simple array to keep all the ballotIds for easier retrieval
access(all) var activeBallotIds: [UInt64] = []

// And this dictionary keeps a list of open Elections in a {electionId (UInt64): electionName (String)}
access(all) var electionList: {UInt64: String} = {}

// Use this index to define the selected Election from a set of available ones
access(all) var selectedElectionIndex: Int = 1
access(all) var selectedElectionId: UInt64 = 0

// The default option set to any newly minted Ballot
access(all) let defaultBallotOption: String = "default"

// And these variables as set points for the selected Election above
access(all) var selectedElectionName: String = ""
access(all) var selectedElectionBallot: String = ""
access(all) var selectedElectionOptions: {UInt8: String} = {}
access(all) var selectedElectionPublicEncryptionKey: [UInt8] = []
access(all) var selectedElectionCapability: Capability<&{ElectionStandard.ElectionPublic}>? = nil

// This is just a handy way to have the voters represented by each of the test account easily. The format of this dictionary is
// {electionName: {accountAddress: electionBallot}}
access(all) var voterOptions: {String: {Address: String}} = {}

access(all) fun setup() {
    var err: Test.Error? = Test.deployContract(
        name: "BallotStandard",
        path: "../contracts/BallotStandard.cdc",
        arguments: [],
    )

    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ElectionStandard",
        path: "../contracts/ElectionStandard.cdc",
        arguments: []
    )

    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "VoteBoxStandard",
        path: "../contracts/VoteBoxStandard.cdc",
        arguments: []
    )

    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "VoteBooth",
        path: "../contracts/VoteBooth.cdc",
        arguments: [verbose]
    )

    Test.expect(err, Test.beNil())

    // The deployment of the VoteBooth contract should emit one ElectionIndexCreated and one VoteBoothPrinterAdminCreated events. Check that
    eventNumberCount[electionIndexCreatedEventType] = eventNumberCount[electionIndexCreatedEventType]! + 1
    eventNumberCount[voteBoothPrinterAdminCreatedEventType] = eventNumberCount[voteBoothPrinterAdminCreatedEventType]! + 1
    validateEvents()

    // Printout the addresses of the test accounts for reference
    if (verbose) {
        log(
            "Deployer account address = "
            .concat(deployer.address.toString())
        )

        for index, account in accounts {
            log(
                "Account 0"
                .concat((index + 1).toString())
                .concat(" address = ")
                .concat(account.address.toString())
            )
        }
    }
}

/**
    Test that all contracts were deployed into the same account. I've created a whole script just to do this.
**/
access(all) fun testDeployerAddress() {
    let scResult: Test.ScriptResult = executeScript(
        testContractConsistencySc,
        []
    )

    Test.expect(scResult, Test.beSucceeded())

    let contractConsistency: Bool = scResult.returnValue as! Bool

    Test.assert(contractConsistency,
        message: "ERROR: Contracts inside the project are not consistent!"
    )
}

/**
    Test that the storage and public paths defined at the contract levels are as expected.
**/
access(all) fun testContractPaths() {
    Test.assert(expectedElectionIndexStoragePath == VoteBooth.electionIndexStoragePath,
        message: "ERROR: Expected ElectionIndexStoragePath = "
        .concat(expectedElectionIndexStoragePath.toString())
        .concat(" but got this instead ")
        .concat(VoteBooth.electionIndexStoragePath.toString())
    )
    
    Test.assert(expectedElectionIndexPublicPath == VoteBooth.electionIndexPublicPath,
        message: "ERROR: Expected ElectionIndexPublicPath = "
        .concat(expectedElectionIndexPublicPath.toString())
        .concat(" but got this instead ")
        .concat(VoteBooth.electionIndexPublicPath.toString())
    )
    
    Test.assert(expectedVoteBoothPrinterAdminStoragePath == VoteBooth.voteBoothPrinterAdminStoragePath,
        message: "ERROR: Expected VoteBoothPrinterAdminStoragePath = "
        .concat(expectedVoteBoothPrinterAdminStoragePath.toString())
        .concat(" but got this instead ")
        .concat(VoteBooth.voteBoothPrinterAdminStoragePath.toString())
    )
    
    Test.assert(expectedVoteBoxStoragePath == VoteBoxStandard.voteBoxStoragePath,
        message: "ERROR: Expected VoteBoxStoragePath = "
        .concat(expectedVoteBoxStoragePath.toString())
        .concat(" but got this instead ")
        .concat(VoteBoxStandard.voteBoxStoragePath.toString())
    )
    
    Test.assert(expectedVoteBoxPublicPath == VoteBoxStandard.voteBoxPublicPath,
        message: "ERROR: Expected VoteBoxPublicPath = "
        .concat(expectedVoteBoxPublicPath.toString())
        .concat(" but got this instead ")
        .concat(VoteBoxStandard.voteBoxPublicPath.toString())
    )
}

/**
    Test the creation of a new Election resource with parameters pre-defined
**/
access(all) fun testCreateElection() {
    // I'm going to create three Elections using the parameter arrays defined in this test script
    var txResult: Test.TransactionResult? = nil

    for index, element in electionNames {
        txResult = executeTransaction(
            createElectionTx, 
            [
                electionNames[index], 
                electionBallots[index],
                electionOptions[index],
                electionPublicEncryptionKeys[index],
                electionStoragePaths[index],
                electionPublicPaths[index]
            ],
            deployer
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // I should have as many ElectionCreated events as the number of Election created in the cycle above. Check it
    eventNumberCount[electionCreatedEventType] = eventNumberCount[electionCreatedEventType]! + electionNames.length
    // Validate that the event count is still consistent
    validateEvents()

    // Grab all the electionIds for the active Elections created above
    var scResult: Test.ScriptResult = executeScript(
        getActiveElectionsSc,
        [nil]
    )

    Test.expect(scResult, Test.beSucceeded())

    // Fill out the activeElectionIds array
    activeElectionIds = scResult.returnValue as! [UInt64]


    // Set the electionId for the Election in question
    selectedElectionIndex = 1
    selectedElectionId = activeElectionIds[selectedElectionIndex]

    // Make sure that all the electionIds and electionNames in the ElectionCreated events emitted are contained in the set of electionIds and electionNames
    var eventElectionId: UInt64 = 0
    var eventElectionName: String = ""

    // Limit the analysis of the electionCreatedEvents to the last ones only
    for electionCreatedEvent in electionCreatedEvents.slice(from: (electionCreatedEvents.length - electionNames.length), upTo: (electionCreatedEvents.length)) {
        let normalisedEvent:ElectionStandard.ElectionCreated = electionCreatedEvent as! ElectionStandard.ElectionCreated
        
        eventElectionId = normalisedEvent._electionId
        eventElectionName = normalisedEvent._electionName

        Test.assert(activeElectionIds.contains(eventElectionId), 
            message: "ERROR: Got an ElectionCreated event with electionId "
            .concat(eventElectionId.toString())
            .concat(" but this Id is not among the activeElectionIds!")
        )

        Test.assert(electionNames.contains(eventElectionName),
            message: "ERROR: Got an ElectionCreated with electionName "
            .concat(eventElectionName)
            .concat(" but this name is not among the ElectionNames! ")
        )
    }

    scResult = executeScript(
        getElectionsListSc,
        []
    )

    Test.expect(scResult, Test.beSucceeded())

    // And now for the election list
    electionList = scResult.returnValue as! {UInt64: String}

    let votingPatterns: {Int: [UInt8]} = {
        0: [3, 5, 2, 3, 1],
        1: [1, 3, 2, 5, 3],
        2: [4, 1, 4, 4, 4]
    }

    // Build the votingOptions dictionary
    for index, electionName in electionNames {
        voterOptions[electionName] = {
            account01.address: electionOptions[index][votingPatterns[index]![0]]!, 
            account02.address: electionOptions[index][votingPatterns[index]![1]]!,
            account03.address: electionOptions[index][votingPatterns[index]![2]]!,
            account04.address: electionOptions[index][votingPatterns[index]![3]]!,
            account05.address: electionOptions[index][votingPatterns[index]![4]]!
        }
    }

    // Validate that this dictionary is consistent
    Test.assert(electionList.length == electionNames.length,
        message: "ERROR: Expected "
        .concat(electionNames.length.toString())
        .concat(" got ")
        .concat(electionList.length.toString())
        .concat(" instead. ")
    )

    for electionId in electionList.keys {
        // Test that the electionIds returned as keys are in the activeElectionIds set
        Test.assert(activeElectionIds.contains(electionId),
            message: "ERROR: The electionId retrieved "
            .concat(electionId.toString())
            .concat(" is not among the ones in the activeElectionIds!")
        )

        // And test that the names returned are also inside the array used to create them.
        Test.assert(electionNames.contains(electionList[electionId]!),
            message: "ERROR: The electionName retrieved "
            .concat(electionList[electionId]!)
            .concat(" is not among the ones in electionNames!")
        )
    }

    // Check that we got the same number of electionIds back
    Test.assert(activeElectionIds.length == electionNames.length,
        message: "ERROR: Got"
        .concat(activeElectionIds.length.toString())
        .concat(" active Elections but expected ")
        .concat(electionNames.length.toString())
    )

    // Use a loop to validate each parameter set in the createElection transaction
    var electionName: String = ""
    var electionBallot: String = ""
    var electionOption: {UInt8: String} = {}
    var electionId: UInt64 = 0
    var electionPublicKey: [UInt8] = []
    var electionCapability: Capability? = nil
    var electionTotals: {String: UInt} = {}
    var electionStoragePath: StoragePath? = nil
    var electionPublicPath: PublicPath? = nil

    for activeElectionId in activeElectionIds {
        // Start with the election names
        scResult = executeScript(
            getElectionNameSc,
            [activeElectionId, nil]
        )

        Test.expect(scResult, Test.beSucceeded())

        // Extract the name from the script result
        electionName = scResult.returnValue as! String

        // Because Cadence does not guarantees the order in which the electionIds were returned, I cannot compare these based on indexes.
        // The next best thing is to ensure that the item returned exits in the set used to construct the Election in the first place.
        Test.assert(electionNames.contains(electionName),
            message: "ERROR: electionName for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionNames!")
        )

        // Repeat for the rest
        // Election Ballot
        scResult = executeScript(
            getElectionBallotSc,
            [activeElectionId, nil]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionBallot = scResult.returnValue as! String

        Test.assert(electionBallots.contains(electionBallot),
            message: "ERROR: electionBallot for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionBallots!")
        )

        // Election Options
        scResult = executeScript(
            getElectionOptionsSc,
            [activeElectionId, nil]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionOption = scResult.returnValue as! {UInt8: String}
        
        Test.assert(electionOptions.contains(electionOption),
            message: "ERROR: electionOptions for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionOptions!")
        )

        // Election Id
        scResult = executeScript(
            getElectionIdSc,
            [activeElectionId, nil]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionId = scResult.returnValue as! UInt64
        Test.assert(activeElectionIds.contains(electionId),
            message: "ERROR: electionId for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in activeElectionIds!")
        )

        // Public Encryption Key
        scResult = executeScript(
            getElectionPublicEncryptionKeySc,
            [activeElectionId, nil]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionPublicKey = scResult.returnValue as! [UInt8]
        Test.assert(electionPublicEncryptionKeys.contains(electionPublicKey),
            message: "ERROR: electionPublicKey for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionPublicEncryptionKeys!")
        )

        // Election Capability
        scResult = executeScript(
            getElectionCapabilitySc,
            [activeElectionId, nil]
        )
        Test.expect(scResult, Test.beSucceeded())
        // If the next force cast succeeds, thats test enough
        electionCapability = scResult.returnValue as! Capability<&{ElectionStandard.ElectionPublic}>

        // Election Ballot totals
        scResult = executeScript(
            getElectionTotalsSc,
            [activeElectionId, nil]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionTotals = scResult.returnValue as! {String: UInt}
        Test.assert(electionTotals["totalBallotsMinted"] == 0,
            message: "ERROR: Election with id "
            .concat(activeElectionId.toString())
            .concat(" has a non-zero totalBallotsMinted: ")
            .concat(electionTotals["totalBallotsMinted"]!.toString())
        )

        Test.assert(electionTotals["totalBallotsSubmitted"] == 0,
            message: "ERROR: Election with id "
            .concat(activeElectionId.toString())
            .concat(" has a non-zero totalBallotsSubmitted: ")
            .concat(electionTotals["totalBallotsSubmitted"]!.toString())
        )

        // Election Storage Path
        scResult = executeScript(
            getElectionStoragePathSc,
            [activeElectionId]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionStoragePath = scResult.returnValue as! StoragePath
        Test.assert(electionStoragePaths.contains(electionStoragePath!),
            message: "The electionStoragePath for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionStoragePaths!")
        )

        // Election Public Path
        scResult = executeScript(
            getElectionPublicPathSc,
            [activeElectionId]
        )
        Test.expect(scResult, Test.beSucceeded())
        electionPublicPath = scResult.returnValue as! PublicPath
        Test.assert(electionPublicPaths.contains(electionPublicPath!),
            message: "The electionPublicPath for activeElectionId "
            .concat(activeElectionId.toString())
            .concat(" is not among the ones in electionPublicPaths!")
        )

        // At the end of this cycle, check if the activeElectionId matches the selectedElectionId and, if so, set the selected set of parameters
        if (selectedElectionId == activeElectionId) {
            selectedElectionName = electionName
            selectedElectionBallot = electionBallot
            selectedElectionOptions = electionOption
            selectedElectionId = electionId
            selectedElectionPublicEncryptionKey = electionPublicKey
            selectedElectionCapability = electionCapability as! Capability<&{ElectionStandard.ElectionPublic}>
        }
    }

}

/**
    Test the creation of a new VoteBox resource into each of the 5 test accounts
**/
access(all) fun testCreateVoteBox() {
    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil

    for account in accounts {
        // Create a new VoteBox resource in each of the user accounts
        txResult = executeTransaction(
            createVoteBoxTx,
            [],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // Validate the VoteBoxCreated events. I should have one per account used
    eventNumberCount[voteBoxCreatedEventType] = eventNumberCount[voteBoxCreatedEventType]! + accounts.length
    validateEvents()

    var eventVoterAddress: Address? = nil
    for voteBoxCreatedEvent in voteBoxCreatedEvents.slice(from: (voteBoxCreatedEvents.length - accounts.length), upTo: (voteBoxCreatedEvents.length)) {
        let normalisedEvent: VoteBoxStandard.VoteBoxCreated = voteBoxCreatedEvent as! VoteBoxStandard.VoteBoxCreated

        eventVoterAddress = normalisedEvent._voterAddress

        Test.assert(accountAddresses.contains(eventVoterAddress!),
            message: "ERROR: VoteBox created for address ".concat(eventVoterAddress!.toString()).concat(" but the address is not among the defined ones!")
        )
    }

    var activeBallots: Int = 0
    // For each voter, grab the list of activeBallots out of their VoteBoxes. Each should be empty
    for account in accounts {
        scResult = executeScript(
            getActiveElectionsSc,
            [account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        // Get the active number of elections for each VoteBox and each account
        activeBallots = (scResult!.returnValue as! [UInt64]).length

        // Each should be empty still
        Test.assert(activeBallots == 0,
            message: "ERROR: The VoteBox created for account "
            .concat(account.address.toString())
            .concat(" has a non-zero count for activeBallots: ")
            .concat(activeBallots.toString())
        )
    }
}

/**
    This test function tries to print a brand new Ballot for Election #1 into each VoteBox in each test account.
**/
access(all) fun testPrintBallotIntoVoteBox() {
    
    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil


    var electionName: String = ""
    var electionBallot: String = ""
    var electionOptions: {UInt8: String} = {}
    var electionId: UInt64 = 0
    var electionPublicEncryptionKey: [UInt8] = []
    var electionCapability: Capability? = nil
    var electionTotals: {String: UInt} = {}
    var electionTotalBallotsMinted: UInt = 0
    var electionTotalBallotsSubmitted: UInt = 0

    log(
        "Printing "
        .concat(accounts.length.toString())
        .concat(" Ballots for Election ")
        .concat(activeElectionIds[selectedElectionIndex].toString())
        .concat(": ")
        .concat(electionList[selectedElectionId]!)
    )
    for account in accounts {
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // Fetch the ballotIds of each Ballot minted into the proper dictionary
    for account in accounts {
        scResult = executeScript(
            getBallotIdSc,
            [account.address, selectedElectionId]
        )

        Test.expect(scResult, Test.beSucceeded())

        let newBallotId: UInt64? = scResult!.returnValue as! UInt64?

        if (newBallotId == nil) {
            panic(
                "ERROR: Unable to get a valid ballotId for the VoteBox in account "
                .concat(account.address.toString())
                .concat(" for electionId ")
                .concat(selectedElectionId.toString())
            )
        }
        else {
            voterBallotIds[account.address]!.append(newBallotId!)
            activeBallotIds.append(newBallotId!)
        }
    }

    // Validate BallotCreated events. I should have one per account used
    eventNumberCount[ballotCreatedEventType] = eventNumberCount[ballotCreatedEventType]! + accounts.length
    validateEvents()

    var eventBallotId: UInt64 = 0
    var eventLinkedElectionId: UInt64 = 0

    for ballotCreatedEvent in ballotCreatedEvents.slice(from: (ballotCreatedEvents.length - accounts.length), upTo: (ballotCreatedEvents.length)) {
        let normalisedEvent: BallotStandard.BallotCreated = ballotCreatedEvent as! BallotStandard.BallotCreated

        eventBallotId = normalisedEvent._ballotId
        eventLinkedElectionId = normalisedEvent._linkedElectionId

        Test.assert(activeBallotIds.contains(eventBallotId),
            message: "ERROR: Got a BallotCreated event with ballotId "
            .concat(eventBallotId.toString())
            .concat(" but this ballotId does not exist in the activeBallotIds list!")
        )

        Test.assert(eventLinkedElectionId == selectedElectionId,
            message: "ERROR: Got a BallotCreated event with a linkedElectionId "
            .concat(eventLinkedElectionId.toString())
            .concat(" but expected this one: ")
            .concat(selectedElectionId.toString())
        )
    }

    // Do another cycle and check, for each account, if the electionName, electionBallot, etc. matches the selected ones
    // Run the getter scripts of before but providing the account address as inputs to trigger the VoteBox retrieval circuit
    for account in accounts {
        scResult = executeScript(
            getElectionNameSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionName = scResult!.returnValue as! String

        Test.assert(electionName == selectedElectionName,
            message: "ERROR: The electionName for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" does not matches the selected one!")
        )

        scResult = executeScript(
            getElectionBallotSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionBallot = scResult!.returnValue as! String

        Test.assert(electionBallot == selectedElectionBallot,
            message: "ERROR: The electionBallot for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" does not matches the selected one!")
        )

        scResult = executeScript(
            getElectionOptionsSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionOptions = scResult!.returnValue as! {UInt8: String}

        Test.assert(electionOptions == selectedElectionOptions,
            message: "ERROR: electionOptions for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" does not matches the selected ones!")
        )

        scResult = executeScript(
            getElectionIdSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionId = scResult!.returnValue as! UInt64

        Test.assert(electionId == selectedElectionId,
            message: "ERROR: electionId for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" does not match the selected one!")
        )

        scResult = executeScript(
            getElectionPublicEncryptionKeySc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionPublicEncryptionKey = scResult!.returnValue as! [UInt8]

        Test.assert(electionPublicEncryptionKey == selectedElectionPublicEncryptionKey,
            message: "ERROR: electionPublicEncryptionKey for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" does not match the selected one!")
        )

        scResult = executeScript(
            getElectionCapabilitySc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionCapability = scResult!.returnValue as! Capability<&{ElectionStandard.ElectionPublic}>

        Test.assertEqual(electionCapability, selectedElectionCapability)

        // Validate the election totals, both through the ElectionIndex and through the VoteBox
        scResult = executeScript(
            getElectionTotalsSc,
            [selectedElectionId, nil]
        )

        Test.expect(scResult, Test.beSucceeded())

        electionTotals = scResult!.returnValue as! {String: UInt}

        electionTotalBallotsMinted = electionTotals["totalBallotsMinted"]!
        electionTotalBallotsSubmitted = electionTotals["totalBallotsSubmitted"]!

        // The Election should have a totalBallotsMinted equal to the number of accounts
        Test.assert(Int(electionTotalBallotsMinted) == accounts.length,
            message: "ERROR: The totalBallotsMinted for election "
            .concat(selectedElectionId.toString())
            .concat(" is set at ")
            .concat(electionTotalBallotsMinted.toString())
            .concat(" but expected ")
            .concat(accounts.length.toString())
        )

        // But not the submitted totals, at least not yet. These should still be 0
        Test.assert(Int(electionTotalBallotsSubmitted) == 0,
            message: "ERROR: The totalBallotsSubmitted for election "
            .concat(selectedElectionId.toString())
            .concat(" is set at ")
            .concat(electionTotalBallotsSubmitted.toString())
            .concat(" but expected 0!")
        )

        // Repeat the call, but from the VoteBox reference side
        scResult = executeScript(
            getElectionTotalsSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        // Update the election totals
        electionTotals = scResult!.returnValue as! {String: UInt}
        electionTotalBallotsMinted = electionTotals["totalBallotsMinted"]!
        electionTotalBallotsSubmitted = electionTotals["totalBallotsSubmitted"]!

        // And test that the same results are consistent from the ones obtained directly from the Election reference.
        Test.assert(Int(electionTotalBallotsMinted) == accounts.length,
            message: "ERROR: The totalBallotsMinted for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" counts at ")
            .concat(electionTotalBallotsMinted.toString())
            .concat(" but expected ")
            .concat(accounts.length.toString())
        )
        Test.assert(Int(electionTotalBallotsSubmitted) == 0,
            message: "ERROR: The totalBallotsSubmitted for election "
            .concat(selectedElectionId.toString())
            .concat(" from a Ballot in account ")
            .concat(account.address.toString())
            .concat(" counts at ")
            .concat(electionTotalBallotsSubmitted.toString())
            .concat(" but expected 0!")
        )
    }

    // Try to re-deposit a new Ballot for the same election into each account and check that the transaction fails.
    for account in accounts {
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beFailed())
    }
}


/**
    This test function attempts to change the option set in each of the Ballots submitted
**/
access(all) fun testCastBallot() {
    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil
    var oldOption: String = ""
    var newOption: String = ""

    // First, start by confirming that, at this point, the option in each Ballot is still set to "default"
    for account in accounts {
        scResult = executeScript(
            getBallotOptionSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        oldOption = scResult!.returnValue as! String

        Test.assert(oldOption == defaultBallotOption, 
            message: "Ballot for Election "
            .concat(selectedElectionId.toString())
            .concat(" does not has the default option set. Instead it has: ")
            .concat(oldOption)
        )

        // Set the new option according to what is set in the voterOptions dictionary
        txResult = executeTransaction(
            castBallotTx,
            [selectedElectionId, voterOptions[selectedElectionName]![account.address]!],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // Run another cycle to check that the Ballot option was set to the proper String value
    for account in accounts {
        scResult = executeScript(
            getBallotOptionSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        newOption = scResult!.returnValue as! String

        Test.assert(newOption == voterOptions[selectedElectionName]![account.address]!, 
            message: "Ballot for Election "
            .concat(selectedElectionId.toString())
            .concat(" does not have the desired option set: ")
            .concat(voterOptions[selectedElectionName]![account.address]!)
            .concat(". Instead it has ")
            .concat(newOption)
        )
    }

    // Do another run with the second option set and ensure all went through
    for account in accounts {
        txResult = executeTransaction(
            castBallotTx,
            [selectedElectionId, voterOptions[selectedElectionName]![account.address]!],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    for account in accounts {
        scResult = executeScript(
            getBallotOptionSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        newOption = scResult!.returnValue as! String

        Test.assert(newOption == voterOptions[selectedElectionName]![account.address],
            message: "Ballot for Election "
            .concat(selectedElectionId.toString())
            .concat(" does not have the desired option set: ")
            .concat(voterOptions[selectedElectionName]![account.address]!)
            .concat(". Instead it has ")
            .concat(newOption)
        )
    }
}

/**
    This test function submits the Ballots to the Elections set in their internal Election capabilities
**/
access(all) fun testSubmitBallot() {
    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil
    var eventBallotId: UInt64 = 0
    var eventElectionId: UInt64 = 0

    for account in accounts {
        txResult = executeTransaction(
            submitBallotTx,
            [selectedElectionId],
            account
        )

        Test.expect(txResult, Test.beSucceeded())

        // If the transaction was successful, grab the event emitted and retrieve the ballotId of the Ballot submitted from it
        // Increment the event count for the BallotSubmitted event
        eventNumberCount[ballotSubmittedEventType] = eventNumberCount[ballotSubmittedEventType]! + 1
        validateEvents()

        // Update the ballot and electionIds from the captured event
        let normalisedEvent: ElectionStandard.BallotSubmitted = ballotSubmittedEvents[ballotSubmittedEvents.length - 1] as! ElectionStandard.BallotSubmitted
        eventBallotId = normalisedEvent._ballotId
        eventElectionId = normalisedEvent._electionId

        Test.assert(activeBallotIds.contains(eventBallotId),
            message: "ERROR: Got an BallotSubmitted event with ballotId "
            .concat(eventBallotId.toString())
            .concat(" but this Id is not among the activeBallotIds!")
        )

        Test.assert(selectedElectionId == eventElectionId,
            message: "ERROR: Got a BallotSubmitted event for Election with id "
            .concat(eventElectionId.toString())
            .concat(" but the Ballot was minted for a selected electionId of ")
            .concat(selectedElectionId.toString())
        )
    }

    // Check that the Election totals are consistent as well. The totalBallotsSubmitted should have been incremented by the number of
    // accounts considered.
    scResult = executeScript(
        getElectionTotalsSc,
        [selectedElectionId, nil]
    )

    Test.expect(scResult, Test.beSucceeded())

    let electionTotals: {String: UInt} = scResult!.returnValue as! {String: UInt}
    
    Test.assert(electionTotals["totalBallotsMinted"]! == UInt(accounts.length),
        message: "ERROR: Election "
        .concat(selectedElectionId.toString())
        .concat(" has ")
        .concat(electionTotals["totalBallotsMinted"]!.toString())
        .concat(" ballots minted, but these should be ")
        .concat(accounts.length.toString())
    )

    Test.assert(electionTotals["totalBallotsSubmitted"]! == UInt(accounts.length),
        message: "ERROR: Election "
        .concat(selectedElectionId.toString())
        .concat(" has ")
        .concat(electionTotals["totalBallotsSubmitted"]!.toString())
        .concat(" ballots submitted, but these should be ")
        .concat(accounts.length.toString())
    )
}

/**
    Mint, cast and re-submit another round of Ballots to each of the test accounts to test the re-submit circuit.
**/
access(all) fun testReSubmitBallots() {
    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil
    var eventBallotId: UInt64 = 0
    var eventLinkedElectionId: UInt64 = 0

    // Start by printing a new Ballot into each of the test accounts. It should be OK now because the old Ballot was submitted already
    for account in accounts {
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beSucceeded())

        // Grab the ballotId from the respective BallotCreated event and append it to the required variables. There's no need to validate every aspect of 
        // this event since this logic was already run before.
        ballotCreatedEvents = Test.eventsOfType(ballotCreatedEventType)

        let ballotCreatedEvent: BallotStandard.BallotCreated = ballotCreatedEvents[ballotCreatedEvents.length - 1] as! BallotStandard.BallotCreated

        eventBallotId = ballotCreatedEvent._ballotId
        eventLinkedElectionId = ballotCreatedEvent._linkedElectionId

        // Validate the electionId retrieved
        Test.assert(eventLinkedElectionId == selectedElectionId,
            message: "ERROR: Got a BallotCreated event with a linkedElectionId "
            .concat(eventLinkedElectionId.toString())
            .concat(" but expected this one: ")
            .concat(selectedElectionId.toString())
        )

        // Append the ballotId obtained to both the activeBallotIds and voterBallotIds
        activeBallotIds.append(eventBallotId)
    }

    // Created accounts.length more Ballots, so I should have +accounts.length more BallotCreated events. Adjust and validate
    eventNumberCount[ballotCreatedEventType] = eventNumberCount[ballotCreatedEventType]! + accounts.length
    validateEvents()

    // Validate the election totals after this step. The total ballots minted should have been increased by the number of test accounts
    scResult = executeScript(
        getElectionTotalsSc,
        [selectedElectionId, nil]
    )

    Test.expect(scResult, Test.beSucceeded())

    var electionTotals: {String: UInt} = scResult!.returnValue as! {String: UInt}
    var electionTotalBallotsMinted: UInt = electionTotals["totalBallotsMinted"]!
    var electionTotalBallotsSubmitted: UInt = electionTotals["totalBallotsSubmitted"]!

    // I should have twice as many Ballots Minted than before
    Test.assert(Int(electionTotalBallotsMinted) == (accounts.length*2),
        message: "ERROR: Mismatch between the totalBallotsMinted for election "
        .concat(selectedElectionId.toString())
        .concat(". Expected ")
        .concat((accounts.length*2).toString())
        .concat(" totalBallotsMinted, got ")
        .concat(electionTotalBallotsMinted.toString())
    )

    // But only one accounts.length worth of totalBallotsSubmitted
    Test.assert(Int(electionTotalBallotsSubmitted) == accounts.length,
        message: "ERROR: Mismatch between the totalBallotsSubmitted for election "
        .concat(selectedElectionId.toString())
        .concat(". Expected ")
        .concat(accounts.length.toString())
        .concat(" totalBallotsSubmitted, got ")
        .concat(electionTotalBallotsSubmitted.toString())
    )

    var newOption: String = ""

    // Cast the new Ballot for each test account. Use the first set of options
    for account in accounts {
        txResult = executeTransaction(
            castBallotTx,
            [selectedElectionId, voterOptions[selectedElectionName]![account.address]!],
            account
        )

        Test.expect(txResult, Test.beSucceeded())

        // This time around, run the script to return the option set in the Ballot and validate that it matches the expected one.
        scResult = executeScript(
            getBallotOptionSc,
            [selectedElectionId, account.address]
        )

        Test.expect(scResult, Test.beSucceeded())

        newOption = scResult!.returnValue as! String

        Test.assert(newOption == voterOptions[selectedElectionName]![account.address],
            message: "ERROR: Ballot "
            .concat(voterBallotIds[account.address]![0].toString())
            .concat(" cast for election ")
            .concat(selectedElectionId.toString())
            .concat(" and for voter ")
            .concat(account.address.toString())
            .concat(" was set with option ")
            .concat(voterOptions[selectedElectionName]![account.address]!)
            .concat(" but the Ballot returned ")
            .concat(newOption)
        )
    }

    // Done. Submit the Ballots in storage
    for account in accounts {
        txResult = executeTransaction(
            submitBallotTx,
            [selectedElectionId],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // This re-submission process does not emit any BallotSubmitted events because these Ballots replace existing ones. Instead, I should have BallotReplace
    // events emitted instead. Validate and test these events as well
    eventNumberCount[ballotReplacedEventType] = eventNumberCount[ballotReplacedEventType]! + accounts.length
    validateEvents()

    var oldBallotId: UInt64 = 0
    var newBallotId: UInt64 = 0
    var electionId: UInt64 = 0

    for ballotReplacedEvent in ballotReplacedEvents.slice(from: ballotReplacedEvents.length - accounts.length, upTo: ballotReplacedEvents.length) {
        let normalisedEvent: ElectionStandard.BallotReplaced = ballotReplacedEvent as! ElectionStandard.BallotReplaced
        oldBallotId = normalisedEvent._oldBallotId
        newBallotId = normalisedEvent._newBallotId
        electionId = normalisedEvent._electionId

        Test.assert(activeBallotIds.contains(oldBallotId),
            message: "ERROR: Got a BallotReplaced event with a oldBallotId "
            .concat(oldBallotId.toString())
            .concat(" but this ballotId does not exist in the activeBallotIds list!")
        )

        Test.assert(activeBallotIds.contains(newBallotId),
            message: "ERROR: Got a BallotReplaced event with a newBallotId "
            .concat(newBallotId.toString())
            .concat(" but this ballotId does not exits in the activeBallotIds list!")
        )

        Test.assert(selectedElectionId == electionId,
            message: "ERROR: Got a BallotReplaced event with an electionId "
            .concat(electionId.toString())
            .concat(" but expected electionId: ")
            .concat(selectedElectionId.toString())
        )
    }


    // Validate the election totals. I should have accounts.length*2 totalBallotsMinted since this is the second round of voting.
    // And I should still have accounts.length totalBallotsSubmitted since the ones in this round are going to replace the old ones,
    // and so the total count should remain the same.
    scResult = executeScript(
        getElectionTotalsSc,
        [selectedElectionId, nil]
    )

    Test.expect(txResult, Test.beSucceeded())

    electionTotals = scResult!.returnValue as! {String: UInt}
    electionTotalBallotsMinted = electionTotals["totalBallotsMinted"]!
    electionTotalBallotsSubmitted = electionTotals["totalBallotsSubmitted"]!

    Test.assert(Int(electionTotalBallotsMinted) == (accounts.length*2),
        message: "ERROR: Mismatch between the totalBallotsMinted for election "
        .concat(selectedElectionId.toString())
        .concat(". Expected ")
        .concat((accounts.length*2).toString())
        .concat(" totalBallotsMinted, got ")
        .concat(electionTotalBallotsMinted.toString())
    )

    Test.assert(Int(electionTotalBallotsSubmitted) == (accounts.length),
        message: "ERROR: Mismatch between the totalBallotsSubmitted for election "
        .concat(selectedElectionId.toString())
        .concat(". Expected ")
        .concat((accounts.length*2).toString())
        .concat(" totalBallotsSubmitted, got ")
        .concat(electionTotalBallotsSubmitted.toString())
    )
    // Done!
}

/**
    This test finalises the base process by withdrawing the Ballots from the Election set in the selectedElectionId 
**/
access(all) fun testTallyElection() {
    // Confirm that the Election state (electionFinished) is still at false
    var scResult: Test.ScriptResult = executeScript(
        isElectionFinishedSc,
        [selectedElectionId]
    )

    Test.expect(scResult, Test.beSucceeded())

    var electionFinished: Bool = scResult.returnValue as! Bool

    Test.assert(!electionFinished, 
        message: "ERROR: Election "
        .concat(selectedElectionId.toString())
        .concat(" is not running any more! ")
    )

    // Before tallying the election, grab the totalBallotsSubmitted for this Election to compare with the total ballots withdrawn
    // from the BallotsWithdrawn event to be emitted during the tally operation
    scResult = executeScript(
        getElectionTotalsSc,
        [selectedElectionId, nil]
    )

    Test.expect(scResult, Test.beSucceeded())

    let electionTotals: {String: UInt} = scResult.returnValue as! {String: UInt}
    let electionTotalBallotsSubmitted: UInt = electionTotals["totalBallotsSubmitted"]!

    // All logic is already encapsulated in the transaction in question. Run it.
    let txResult: Test.TransactionResult = executeTransaction(
        tallyElectionTx,
        [selectedElectionId],
        deployer
    )

    Test.expect(txResult, Test.beSucceeded())

    // The tally election transaction should've emit the BallotsWithdrawn event. Test and capture it
    eventNumberCount[ballotsWithdrawnEventType] = eventNumberCount[ballotsWithdrawnEventType]! + 1
    validateEvents()

    let ballotsWithdrawnEvent: ElectionStandard.BallotsWithdrawn = ballotsWithdrawnEvents[ballotsWithdrawnEvents.length - 1] as! ElectionStandard.BallotsWithdrawn

    let eventTotalBallots: UInt = ballotsWithdrawnEvent._ballotsWithdrawn
    let eventElectionId: UInt64 = ballotsWithdrawnEvent._electionId

    Test.assert(eventElectionId == selectedElectionId,
        message: "ERROR: Got a BallotsWithdrawn event with an electionId "
        .concat(eventElectionId.toString())
        .concat(" but expected electionId: ")
        .concat(selectedElectionId.toString())
    )

    // Compare the totalBallotsSubmitted from the Election with the total ballots withdrawn from the BallotsWithdrawn event
    Test.assert(electionTotalBallotsSubmitted == eventTotalBallots,
        message: "ERROR: Got a BallotsWithdrawn event for election "
        .concat(eventElectionId.toString())
        .concat(" with ")
        .concat(eventTotalBallots.toString())
        .concat(" ballots withdrawn from it, but the Election was reporting ")
        .concat(electionTotalBallotsSubmitted.toString())
        .concat(" total ballots submitted!")
    )

    // Validate that the election state changed for true
    scResult = executeScript(
        isElectionFinishedSc,
        [selectedElectionId]
    )

    electionFinished = scResult.returnValue as! Bool

    Test.assert(electionFinished, 
        message: "ERROR: Election "
        .concat(selectedElectionId.toString())
        .concat(" is still running! ")
    )

    // Grab the winningOption from the election
    scResult = executeScript(
        getElectionResultsSc,
        [selectedElectionId]
    )

    Test.expect(scResult, Test.beSucceeded())

    var winningOptions: {String: Int} = scResult.returnValue as! {String: Int}

    // Check that something was indeed returned
    Test.assert(winningOptions != {},
        message: "ERROR: Election "
        .concat(selectedElectionId.toString())
        .concat(" did not produced any results!")
    )

    // Log out the Election results
    log("Election ".concat(selectedElectionId.toString()).concat(" voting statistics: "))
    log(winningOptions)
}

/**
    This test destroys the remaining process structures created during the voting process just to test that the account storage does gets cleaned and all the relevant events are emitted as expected.
    1. Load the VoteBoxes and some of the Elections with some Ballots. Take note of the numbers
    2. Run the burn transactions for the VoteBoxes and VoteBooth
    3. Validate that the events emitted through the process match with the expected numbers
**/
access(all) fun testCleanEnvironment() {
    // Start by populating another Election and the VoteBoxes in each test account with some Ballots before cleaning the environment, just to be sure that
    // each resource is properly deleted and all the expected events are emitted

    var txResult: Test.TransactionResult? = nil
    var scResult: Test.ScriptResult? = nil

    // Before anything else, the election set with the current selectedElectionId is already finished. Trying to cast new Ballots into it
    // should fail. Test it
    for account in accounts {
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beFailed())
    }

    // All good. Switch the electionIndexer to the next available value and repeat the process
    selectedElectionIndex = (selectedElectionIndex + 1) % activeElectionIds.length
    selectedElectionId = activeElectionIds[selectedElectionIndex]

    // Load another set of Ballots into the test account's VoteBoxes
    for account in accounts{
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // Cast each of these Ballots according to the voterOption3
    for account in accounts {
        txResult = executeTransaction(
            castBallotTx,
            [selectedElectionId, voterOptions[selectedElectionName]![account.address]!],
            account
        )

        Test.expect(txResult, Test.beSucceeded())


        // And submit it right away
        txResult = executeTransaction(
            submitBallotTx,
            [selectedElectionId],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // Validate that this action emitted accounts.length BallotCreated events
    eventNumberCount[ballotCreatedEventType] = eventNumberCount[ballotCreatedEventType]! + accounts.length

    // And the BallotSubmitted ones as well
    eventNumberCount[ballotSubmittedEventType] = eventNumberCount[ballotSubmittedEventType]! + accounts.length
    validateEvents()

    // Run another cycle to populate the VoteBoxes with another round of Ballots
    for account in accounts {
        txResult = executeTransaction(
            createBallotTx,
            [selectedElectionId, account.address],
            deployer
        )

        Test.expect(txResult, Test.beSucceeded())

        // And cast them just in case as well
        txResult = executeTransaction(
            castBallotTx,
            [selectedElectionId, voterOptions[selectedElectionName]![account.address]!],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // The BallotCreated events should have been increased by account.length and nothing more
    eventNumberCount[ballotCreatedEventType] = eventNumberCount[ballotCreatedEventType]! + accounts.length
    validateEvents()

    // All good. Proceed with the deletion of all test account VoteBoxes.
    for account in accounts {
        txResult = executeTransaction(
            destroyVoteBoxTx,
            [],
            account
        )

        Test.expect(txResult, Test.beSucceeded())
    }

    // After this one, I expect to have accounts.length VoteBoxDestroyed events and as many BallotDestroyed events as well
    eventNumberCount[voteBoxDestroyedEventType] = eventNumberCount[voteBoxDestroyedEventType]! + accounts.length
    eventNumberCount[ballotBurnedEventType] = eventNumberCount[ballotBurnedEventType]! + accounts.length
    validateEvents()

    // All good. Proceed with the destruction of all active Elections, the ElectionIndex and the VoteBoothPrinterAdmin resource as well
    let activeElections: Int = activeElectionIds.length

    txResult = executeTransaction(
        cleanupVoteBoothTx,
        [],
        deployer
    )

    Test.expect(txResult, Test.beSucceeded())

    // Test if the expected events were emitted
    // I shall have activeElections ElectionDestroyed events
    eventNumberCount[electionDestroyedEventType] = eventNumberCount[electionDestroyedEventType]! + activeElections
    // Also, because one of the Elections had accounts.length Ballots submitted into it when it was destroyed, I should also have
    // accounts.length BallotBurned extra events
    eventNumberCount[ballotBurnedEventType] = eventNumberCount[ballotBurnedEventType]! + accounts.length

    // Validate the ElectionIndexDestroyed and VoteBoothBallotPrinterAdminDestroyed events also
    eventNumberCount[electionIndexDestroyedEventType] = eventNumberCount[electionIndexDestroyedEventType]! + 1
    eventNumberCount[voteBoothPrinterAdminDestroyedEventType] = eventNumberCount[voteBoothPrinterAdminDestroyedEventType]! + 1
    validateEvents()

    // Check also that the electionId of each destroyed Election matches with one of the ones in activeElectionIds
    var electionId: UInt64 = 0
    var ballotsStored: UInt = 0

    for electionDestroyedEvent in electionDestroyedEvents.slice(from: electionDestroyedEvents.length - activeElections, upTo:electionDestroyedEvents.length) {
        let normalisedEvent: ElectionStandard.ElectionDestroyed = electionDestroyedEvent as! ElectionStandard.ElectionDestroyed

        electionId = normalisedEvent._electionId
        ballotsStored = normalisedEvent._ballotsStored

        Test.assert(activeElectionIds.contains(electionId),
            message: "ERROR: Got an ElectionDestroyed event with an electionId "
            .concat(electionId.toString())
            .concat(" but this id is not among the ones in the activeElectionIds!|")
        )

        // Don't bother testing the ballotsStored since one of these elections had some when it got destroyed and the others didn't.
        // It is hard to determine which ones are, but given how non-vital this parameter is, ignore it for now
    }

    // And that's about it!
}