//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./DAO.sol";
import "./FactorySigner.sol";

contract DAOFactory is Ownable,FactorySigner{

    struct DAOInfo{
        address owner;
        address DAOAddress;
        uint[] team;
        string metadata;
    }

    mapping(address=>uint[]) public userDAOs;
    mapping(uint => DAOInfo) public info;

    uint public DAOID;

    event DAOCreated(address DAO,address indexed creator);

    constructor(uint _price) FactorySigner("GitDAO","1"){
    }

    modifier contains (string memory what, string memory where) {
        bytes memory whatBytes = bytes (what);
        bytes memory whereBytes = bytes (where);

        require(whereBytes.length >= whatBytes.length);

        bool found = false;
        for (uint i = 0; i <= whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint j = 0; j < whatBytes.length; j++)
                if (whereBytes [i + j] != whatBytes [j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                found = true;
                break;
            }
        }
        require (found);
        _;
    }

    function createGitDAO(Proposal memory proposal,uint[] memory partners,uint[] memory shares,
    uint fees,string memory metadata,string memory tokenName,string memory tokenSymbol
    ) external {
        //TODO: Change to clone proxy
        DAOID++;
        DAO newDAO = new DAO(msg.sender,proposal.repoName,partners,shares,fees,metadata,tokenName,tokenSymbol);
        info[DAOID] = DAOInfo(address(newDAO),msg.sender,partners,metadata);
        userDAOs[msg.sender].push(DAOID);
        emit DAOCreated(address(newDAO), msg.sender);
    }

    function getUserDAOCount(address _user) external view returns(uint){
        return userDAOs[_user].length;
    }

    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

}