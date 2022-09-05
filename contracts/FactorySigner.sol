//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract FactorySigner is EIP712{

    struct Proposal{
        string repoURL;
        string repoName;
        address user;
        bytes signature;
    }

    constructor(string memory SIGNING_DOMAIN,string memory SIGNATURE_VERSION) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION){
        
    }

    function getSigner(Proposal memory result) public view returns(address){
        return _verify(result);
    }
  
    function _hash(Proposal memory result) internal view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(
      keccak256("Proposal(string repoURL,string repoName,address user)"),
      keccak256(bytes(result.repoURL)),
      keccak256(bytes(result.repoName)),
      result.user
    )));
    }

    function _verify(Proposal memory result) internal view returns (address) {
        bytes32 digest = _hash(result);
        return ECDSA.recover(digest, result.signature);
    }

}