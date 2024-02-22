// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.9.3/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts@4.9.3/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts@4.9.3/access/Ownable.sol";

contract TTCreatorDeploy is EIP712, Ownable {
    mapping (address => bool) public creators;
    bytes32 private constant _PERMIT_TYPEHASH = keccak256("Permit(address creator,uint256 deadline)");  
    mapping(bytes => bool) private hashList;
    address private signAddress;
    uint256 public createPirce = 1 ether;

    event Create(string tokenName, string tokenSymbol, string icon, address creator, uint256 deadline, bytes signature);

    constructor( address _signAddress) EIP712('TTCreatorDeploy', '1') {
        signAddress = _signAddress;
    }

    function create(string memory tokenName, string memory tokenSymbol, string memory icon, address creator, uint256 deadline, bytes memory signature) public payable {
        require(msg.sender == creator, "not owner");
        require(block.timestamp <= deadline, "already expired");
        require(msg.value == createPirce, "BNB limit");
        require(!creators[msg.sender], "already created");
        require(!hashList[signature], "hash is used");
        hashList[signature] = true;
        creators[msg.sender] = true;
        require(isSigner(creator, deadline, signature), "data is wrong");
        
        emit Create(tokenName, tokenSymbol, icon, creator, deadline, signature);
    }

    function isSigner(address creator, uint256 deadline, bytes memory signature) private view returns (bool) {
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, creator, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        address signer = ECDSA.recover(hash, v, r, s);
        return signer == signAddress;
    }

    function setCreatePrice(uint256 _createPirce) public onlyOwner {
        createPirce = _createPirce;
    }

    function withdrawBNB(address to, uint256 amount) public onlyOwner {
        payable(to).transfer(amount);
    }
}

