// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract DefiOSNameSigner is EIP712{

    struct DefiOSName{
        string github_username;
        address corresponding_pubkey;
        bytes signature;
    }

    constructor(string memory SIGNING_DOMAIN,string memory SIGNATURE_VERSION) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        
    }

    function getSigner(DefiOSName memory result) public view returns(address){
        return _verify(result);
    }
  
    function _hash(DefiOSName memory result) internal view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("DefiOSName(string github_username,address corresponding_pubkey)"),
                    keccak256(bytes(result.github_username)),
                    result.corresponding_pubkey
                )
            )
        );
    }

    function _verify(DefiOSName memory result) internal view returns (address) {
        bytes32 digest = _hash(result);
        return ECDSA.recover(digest, result.signature);
    }
}