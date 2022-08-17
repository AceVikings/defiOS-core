//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Signer.sol";

contract DAO is Ownable{

    struct Issue{
        uint startTime;
        address user;

    }

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    // function createIssue() external {
    //     require()
    // }


}