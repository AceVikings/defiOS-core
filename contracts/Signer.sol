//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract Signer is EIP712{

    struct Proposal{
        bytes32 issue;
        uint amount;
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
      keccak256("Proposal(bytes32 issue,uint amount,address user)"),
      result.issue,
      result.amount,
      result.user
    )));
    }

    function _verify(Proposal memory result) internal view returns (address) {
        bytes32 digest = _hash(result);
        return ECDSA.recover(digest, result.signature);
    }

}