//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Signer.sol";
import "./Token.sol";

contract DAO is Ownable{

    enum IssueState { OPEN, VOTING, WINNERCHOSEN, CLOSED }

    struct stakerInfo{
        address staker;
        uint amount;
        bool voted;
    }

    struct collaboratorInfo{
        address collaborator;
        string proof;
        uint votes;
    }

    struct Issue{
        string issueURL;
        address creator;
        IssueState state;
        uint totalStaked;
        address solver;
    }

    // struct Commit {
    //     string working_tree_hash;
    //     string commit_hash;
    //     IssueState state;
    //     CommitType commit_type;
    // }

    // struct Issue {
    //     string issue_url;
    //     address issue_creator;
    //     IssueState state;
    //     mapping(string => mapping(address=>uint256)) issue_stakers;
    //     address issue_solver_wallet;
    //     mapping(string=>uint256) possible_solution_start_commit_hash;
    //     mapping(string=>uint256) possible_solution_end_commit_hash;
    //     Commit solution_start_commit;
    //     Commit solution_end_commit;
    // }

    IERC20 TOKEN;

    string public NAME;
    string public METADATA;

    address[] public TEAM;
    uint public FEES;

    uint public issueID;

    mapping(uint256=>Issue) repoIssues;
    mapping(uint256=>stakerInfo[]) stakers;
    mapping(uint256=>collaboratorInfo[]) collaborators;
    mapping(string=>bool) issueInitiated;

    // constructor - all about creating the ERC20 and determining the initial distribution of these ERC20 tokens
    constructor(address _owner,string memory repo_name,address[] memory team,uint[] memory shares,
        uint dao_fees,string memory metadata, string memory tokenName,string memory tokenSymbol) {
        transferOwnership(_owner);
        NAME = repo_name;
        TEAM = team;
        FEES = dao_fees;
        METADATA = metadata;
        TOKEN = new Token(tokenName,tokenSymbol,team,shares);
    }
    
    modifier onlyHolder{
        require(TOKEN.balanceOf(msg.sender) > 0,"Not holder");
        _;
    }

    function createIssue(string memory url,uint initialStake) external onlyHolder{
        require(!issueInitiated[url],"Duplicate issue");
        TOKEN.transferFrom(msg.sender,address(this),initialStake);
        issueID++;
        repoIssues[issueID] = Issue(url,msg.sender,IssueState.OPEN,initialStake,address(0));
        stakers[issueID].push(stakerInfo(msg.sender,initialStake,false));
        issueInitiated[url] = true;
    }

    function stakeOnIssue(uint issue,uint amount) external {
        require(issue <= issueID && issue != 0,"Invalid issue");
        require(repoIssues[issue].state == IssueState.OPEN,"Issue not open");
        TOKEN.transferFrom(msg.sender,address(this),amount);
        repoIssues[issue].totalStaked += amount;
    }   

    function voteOnIssue(uint issue,uint collboratorId,uint stakerId) external {
        require(repoIssues[issue].state == IssueState.VOTING,"Not voting");
        require(!stakers[issue][stakerId].voted,"Already voted");
        require(stakers[issue][stakerId].staker == msg.sender,"Invalid user");
        collaborators[issue][collboratorId].votes += stakers[issue][stakerId].amount;
    }

    function addCollaborator(uint issue,address collaborator,string memory proof) external onlyOwner{
        require(issue <= issueID && issue != 0,"Invalid issue");
        require(repoIssues[issue].state == IssueState.OPEN,"Issue not open");
        collaborators[issue].push(collaboratorInfo(collaborator,proof,0));
    }

    function startVoting(uint issue) external onlyOwner{
        require(collaborators[issue].length > 0,"No collaborators to vote");
        _changeIssueState(issue, 1);
    }

    function chooseWinner(uint issue) external onlyOwner{
        require(repoIssues[issue].state == IssueState.VOTING,"Issue not voting");
        bool selected = false; 
        for(uint i=0;i<collaborators[issue].length;i++){
            if(collaborators[issue][i].votes > repoIssues[issue].totalStaked/2){
                repoIssues[issue].solver = collaborators[issue][i].collaborator;
                selected = true;
            } 
        }
        require(selected,"No majority reached");
        _changeIssueState(issue, 2);
    }

    function redeemRewards(uint issue) external {
        require(repoIssues[issue].state == IssueState.WINNERCHOSEN,"Winner not chosen or already paid");
        _changeIssueState(issue, 3);
        uint amount = repoIssues[issue].totalStaked;
        TOKEN.transfer(repoIssues[issue].solver,amount);
    }

    function _changeIssueState(uint issue,uint8 state) private{
        require(issue <= issueID && issue != 0,"Invalid issue");
        repoIssues[issue].state = IssueState(state);
    }

    // Methods:
    // create_issue() - which will just take metadata and push into the repo_issues mapping. payable 0.002 matic/sol
    // change_issue_state() - creator can call to change issue state
    // stake_on_issue() - checks is state is open then it stakes the tokens
    // submit_solution() - allows all stakers to submit what they think is the right solution to the problem
    // close_solution_submission() - to be called within submit_solution if all stakers have finished voting or it can be called by the dao owner
    // redeem_rewards() - if state is winnerdeclared anyone can call this function and the amount will go to the winner
    // add_commits() - basically this is a function where like the repo owner can add a commit to the commit history and stake a particular amount on the correctness of the commit hash and the tree hash
    // read_commit() - returns repo_commits object
    // function createIssue() external {
    //     require()
    // }





}