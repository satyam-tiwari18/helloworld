// Simple-Voting-Basic-voting-system-with-candidate-registration-and-vote-counting/
// ├── contracts/
// │   └── Project.sol
// ├── README.md
// └── package.json

// contracts/Project.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    // State variables
    address public owner;
    bool public votingActive;
    uint256 public totalVotes;
    
    // Candidate structure
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    uint256[] public candidateIds;
    
    // Events
    event CandidateRegistered(uint256 indexed candidateId, string name);
    event VoteCasted(uint256 indexed candidateId, address indexed voter);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        votingActive = false;
        totalVotes = 0;
    }
    
    // Core Function 1: Register Candidate
    function registerCandidate(uint256 _candidateId, string memory _name) 
        external 
        onlyOwner 
    {
        require(!candidates[_candidateId].exists, "Candidate already exists");
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidates[_candidateId] = Candidate({
            id: _candidateId,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        candidateIds.push(_candidateId);
        
        emit CandidateRegistered(_candidateId, _name);
    }
    
    // Core Function 2: Cast Vote
    function vote(uint256 _candidateId) 
        external 
        votingIsActive 
        hasNotVoted 
    {
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
        totalVotes++;
        
        emit VoteCasted(_candidateId, msg.sender);
    }
    
    // Core Function 3: Get Vote Results
    function getResults() 
        external 
        view 
        returns (uint256[] memory, string[] memory, uint256[] memory) 
    {
        uint256 candidateCount = candidateIds.length;
        string[] memory names = new string[](candidateCount);
        uint256[] memory votes = new uint256[](candidateCount);
        
        for (uint256 i = 0; i < candidateCount; i++) {
            uint256 candidateId = candidateIds[i];
            names[i] = candidates[candidateId].name;
            votes[i] = candidates[candidateId].voteCount;
        }
        
        return (candidateIds, names, votes);
    }
    
    // Additional utility functions
    function toggleVoting() external onlyOwner {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    function getCandidateCount() external view returns (uint256) {
        return candidateIds.length;
    }
    
    function getCandidate(uint256 _candidateId) 
        external 
        view 
        returns (uint256, string memory, uint256) 
    {
        require(candidates[_candidateId].exists, "Candidate does not exist");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
