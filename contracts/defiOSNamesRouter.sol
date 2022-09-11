// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./defiOSNameSigner.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DefiOSNamesRouter is Ownable, DefiOSNameSigner {
    mapping(string=>address) public name_to_address_map;
    mapping(address=>string) public address_to_name_map;
    address router_creator;

    constructor() DefiOSNameSigner("defi-os.com", "1"){
        router_creator = msg.sender;
    }

    function add_name(DefiOSName memory defi_os_name) external returns(address){
        require(router_creator == getSigner(defi_os_name), "Incorrectly signed username verification request");
        require(name_to_address_map[defi_os_name.github_username]==address(0), "Username mapping already exists");
        name_to_address_map[defi_os_name.github_username] = defi_os_name.corresponding_pubkey;
        address_to_name_map[defi_os_name.corresponding_pubkey] = defi_os_name.github_username;
        return msg.sender;
    }

    function setRouterCreator(address _creator) external onlyOwner{
        router_creator = _creator;
    }

}