//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{

    struct partnerInfo{
        uint amount;
        bool claimed;
    }

    uint public constant TOTAL_SUPPLY = 10_000_000 ether;

    mapping(uint => partnerInfo) public partner;

    //@dev max supply of 10M 
    //@dev team supply should be less tha 1M and rest is minted to owner
    //@dev owner is expected to be user 0 in the list
    constructor(string memory name,string memory symbol,uint[] memory users,uint[] memory tokens) ERC20(name,symbol){
        require(users.length == tokens.length,"Length mismatch");
        uint amount = 0;
        for(uint i = 0;i<users.length;i++){
            amount += tokens[i];
            partner[users[i]] = partnerInfo(tokens[i],false);
        }
        require(amount <= 1_000_000 ether,"Team share can't exceed 1M");
        // _mint(users[0],TOTAL_SUPPLY - amount);
    }

    function claimShare(uint partnerId) external {
        require(!partner[partnerId].claimed,"Already claimed");
        partner[partnerId].claimed = true;
    }

    function mint(address to,uint amount) external {
        _mint(to,amount);
    }

}