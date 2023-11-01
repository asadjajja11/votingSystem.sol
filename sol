// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Ballot {
    // Variables
    struct vote {
        address voterAddress; // Address of the voter
        bool choice; // Voter's choice (true for yes, false for no)
    }

    struct voter {
        address voterAddress; // Address of the voter
        string voterName; // Name of the voter
        bool voted; // Boolean to track if the voter has voted
    }

    uint256 private countResult = 0; // Private variable to count the results
    uint256 public finalResult = 0; // Public variable to store the final result

    uint256 public totalVotes = 0; // Total number of votes
    uint256 public totalVoters = 0; // Total number of registered voters

    address ballotOfficialAddress; // Address of the ballot official
    string ballotOfficialName; // Name of the ballot official
    string proposal; // The proposal being voted on

    mapping(uint256 => vote) private votes; // Mapping to store vote results
    mapping(address => voter) public voterRegister; // Mapping to register voters

    enum State {
        Created, // Initial state when the ballot is created
        Voting, // State when the voting is in progress
        Ended // State when the voting has ended
    }

    State public state; // Current state of the ballot

    // Modifiers
    modifier condition(bool _condition) {
        require(_condition, "Condition not met");
        _;
    }

    modifier onlyOfficial() {
        require(
            msg.sender == ballotOfficialAddress,
            "Only the official can perform this action"
        );
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state transition");
        _;
    }

    // Constructor
    constructor(string memory _ballotOfficialName, string memory _proposal) {
        ballotOfficialName = _ballotOfficialName; // Initialize the official's name
        proposal = _proposal; // Initialize the proposal
        ballotOfficialAddress = msg.sender; // Set the official's address to the contract deployer
        state = State.Created; // Set the initial state to Created
    }

    // Add voter function
    function addVoter(string memory _voterName, address _voterAddress)
        public
        inState(State.Created) // Ensure the contract is in the Created state
        onlyOfficial // Only the official can add voters
    {
        voter memory v;
        v.voterAddress = _voterAddress; // Set the voter's address
        v.voterName = _voterName; // Set the voter's name
        v.voted = false; // Initialize voted status as false
        voterRegister[_voterAddress] = v; // Register the voter
        totalVoters++; // Increment the total voter count
    }

    // Start voting function
    function startVote() public inState(State.Created) onlyOfficial {
        state = State.Voting; // Transition the state to Voting
    }

    // Do vote function
    function doVote(bool _choice) public inState(State.Voting) returns (bool) {
        require(
            bytes(voterRegister[msg.sender].voterName).length != 0,
            "You are not a registered voter"
        ); // Check if the voter is registered
        require(!voterRegister[msg.sender].voted, "You have already voted"); // Check if the voter has not voted

        voterRegister[msg.sender].voted = true; // Mark the voter as voted

        vote memory v;
        v.voterAddress = msg.sender; // Set the voter's address in the vote record
        v.choice = _choice; // Record the voter's choice
        if (_choice) {
            countResult++; // If the choice is yes, increment the countResult
        }
        votes[totalVotes] = v; // Store the vote record
        totalVotes++; // Increment the total vote count

        return true;
    }

    // End voting function
    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended; // Transition the state to Ended
    }
}
