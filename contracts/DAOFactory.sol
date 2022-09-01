//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./DAO.sol";
import "./FactorySigner.sol";

contract DAOFactory is Ownable,FactorySigner{

    uint public PRICE;

    struct DAOInfo{
        address owner;
        address[] team;
        string metadata;
    }

    mapping(address=>uint[]) userDAOs;
    mapping(uint => DAOInfo) info;

    constructor(uint _price) FactorySigner("GitDAO","1"){
        PRICE = _price;
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

    function createGitDAO(Proposal memory proposal,address[] memory partners,uint[] memory shares,
    uint fees,string memory metadata,string memory tokenName,string memory tokenSymbol
    ) external payable contains(Strings.toHexString(msg.sender),proposal.repoName){
        require(msg.value >= PRICE,"Underpaid");
        //TODO: Change to clone proxy
        new DAO(msg.sender,proposal.repoName,partners,shares,fees,metadata,tokenName,tokenSymbol);
    }


    function setPrice(uint _price) external onlyOwner{
        PRICE = _price;
    }

    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }

}