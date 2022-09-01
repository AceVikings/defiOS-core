//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{

    uint public constant TOTAL_SUPPLY = 10_000_000 ether;

    //@dev max supply of 10M 
    //@dev team supply should be less tha 1M and rest is minted to owner
    //@dev owner is expected to be user 0 in the list
    constructor(string memory name,string memory symbol,address[] memory users,uint[] memory tokens) ERC20(name,symbol){
        require(users.length == tokens.length,"Length mismatch");
        uint amount = 0;
        for(uint i = 0;i<users.length;i++){
            amount += tokens[i];
            _mint(users[i],tokens[i]);
        }
        require(amount <= 1_000_000 ether,"Team share can't exceed 1M");
        _mint(users[0],TOTAL_SUPPLY - amount);
    }

}