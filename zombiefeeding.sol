pragma solidity ^0.4.19;

// import
import "./zombiefactory.sol";

// Eating cryptokitties
// For our contract to talk to another contract on the blockchain that we don't own,
// first we need to define an interface

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

// inheritance
contract ZombieFeeding is ZombieFactory {

    // modifier to check the zombie owner
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    // since contracts are immutable, crypto kittie contract address will
    // be set from outside to avoid fails from their contract  = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d
    // init interface
    KittyInterface kittyContract;

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

    // 1. Define `_triggerCooldown` function here
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }
    // 2. Define `_isReady` function here
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    // In Solidity, there are two places you can store variables — in storage and in memory.
    // Storage refers to variables stored permanently on the blockchain.
    // Memory variables are temporary, and are erased between external function calls to your contract.
    // Think of it like your computer's hard disk vs RAM.

    // State variables (variables declared outside of functions) are by default storage and written permanently to the blockchain,
    // while variables declared inside functions are memory and will disappear when the function call ends.

    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        // check time to wait expired
        require(_isReady(myZombie));
        // make sure that _targetDna isn't longer than 16 digits
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        if (keccak256(_species) == keccak256("kitty")) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        // set the zombie a new countdown
        _triggerCooldown(myZombie);
    }

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

}