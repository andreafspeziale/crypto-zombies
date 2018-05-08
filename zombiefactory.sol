pragma solidity ^0.4.19;

// import
import "./ownable.sol";
import "./lib/safemath.sol";

contract ZombieFactory is Ownable{

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // cooldown for zombie attach time to wait
    uint cooldownTime = 1 days;

    // You'll also want to cluster identical data types together
    // (i.e. put them next to each other in the struct) so that Solidity
    // can minimize the required storage space - LESS GAS

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        // Zombie Wins and Losses
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // private means it's only callable from other functions inside the contract
    // public can be called anywhere, both internally and externally

    // In addition to public and private,
    // Solidity has two more types of visibility for functions: internal and external

    // internal is the same as private,
    // except that it's also accessible to contracts that inherit from this contract

    // external is similar to public, except that these functions can ONLY be called outside the contract — they can't be called by other functions inside that contract.

    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // assign to address a Zombie
        zombieToOwner[id] = msg.sender;
        // increase number of Zombie of the owner
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // the function will throw an error and stop executing if some condition is not true
        require(ownerZombieCount[msg.sender]==0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}