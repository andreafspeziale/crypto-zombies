pragma solidity ^0.4.19;
import "./zombieattack.sol";
import "./erc721.sol";

// all the ERC721 logic

// ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible.
// You can only trade them in whole units, and each one has a unique ID.
// So these are a perfect fit for making our zombies tradeable.


/*

    list of methods we'll need to implement

    contract ERC721 {
      event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
      event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

      function balanceOf(address _owner) public view returns (uint256 _balance);
      function ownerOf(uint256 _tokenId) public view returns (address _owner);
      function transfer(address _to, uint256 _tokenId) public;
      function approve(address _to, uint256 _tokenId) public;
      function takeOwnership(uint256 _tokenId) public;
    }

*/

/// @title: A contract that manages transfering zombie ownership;
/// @author: Andrea
/// @dev: Compliant with OpenZeppelin's implementation of the ERC721 spec draft
contract ZombieOwnership is ZombieAttack, ERC721 {

    // when someone calls takeOwnership with a _tokenId, we can use this mapping to quickly look up who is approved to take that token
    mapping (uint => address) zombieApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        // 1. Return the number of zombies `_owner` has here
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        // 2. Return the owner of `_tokenId` here
        return zombieToOwner[_tokenId];
    }

    // abstract transfer function logic use by both transfer and approve functions
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // increment ownerZombieCount for the person receiving the zombie (address _to)
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        // decrease the ownerZombieCount for the person sending the zombie (address _from)
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        // change zombieToOwner mapping for this _tokenId so it now points to _to
        zombieToOwner[_tokenId] = _to;
        // fire Transfer with the correct information
        Transfer(_from, _to, _tokenId);
    }

    // token's owner calls transfer with the address he wants to transfer to, and the _tokenId of the token he wants to transfer
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    // ********************************************

    // token's owner first calls approve, and sends it the same info as above.
    // The contract then stores who is approved to take a token, usually in a mapping (uint256 => address). Then when someone calls takeOwnership, the contract checks if that msg.sender is approved by the owner to take the token, and if so it transfers the token to him

    //  the owner, call approve and give it the address of the new owner, and the _tokenId you want him to take
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId);
    }
    // new owner calls takeOwnership with the _tokenId, the contract checks to make sure he's already been approved, and then transfers him the token
    function takeOwnership(uint256 _tokenId) public {
        // check to make sure the msg.sender has been approved to take this token / zombie, and call _transfer if so
        require(zombieApprovals[_tokenId] == msg.sender);

    }
}
