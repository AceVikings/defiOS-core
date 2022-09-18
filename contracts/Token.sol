//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface defiOSRouter{
    function name_to_address_map(string memory name) external view returns(address);
}
interface Factory{
    function Router() external view returns(address);
}
contract Token is ERC20{

    struct partnerInfo{
        uint amount;
        bool claimed;
    }

    uint public constant TOTAL_SUPPLY = 1_000_000 ether;

    mapping(string => partnerInfo) public partner;

    Factory factory;
    //@dev max supply of 10M 
    //@dev team supply should be less tha 1M and rest is minted to owner
    //@dev owner is expected to be user 0 in the list
    constructor(string memory name,string memory symbol,string[] memory users,uint[] memory tokens,address _factory) ERC20(name,symbol){
        require(users.length == tokens.length,"Length mismatch");
        uint amount = 0;
        for(uint i = 0;i<users.length;i++){
            amount += tokens[i];
            partner[users[i]] = partnerInfo(tokens[i],false);
        }
        require(amount <= 250_000 ether,"Team share can't exceed 1M");
        factory = Factory(_factory);
    }

    function claimShare(string memory partnerId) external {
        require(!partner[partnerId].claimed,"Already claimed");
        require(defiOSRouter(factory.Router()).name_to_address_map(partnerId) == msg.sender,"Invalid sender");
        partner[partnerId].claimed = true;
        _mint(msg.sender,partner[partnerId].amount);
    }


}