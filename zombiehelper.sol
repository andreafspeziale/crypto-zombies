pragma solidity ^0.4.19;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    // static fee to be paid to rank up a zombie
    uint levelUpFee = 0.001 ether;

    // payable functions are part of what makes Solidity and Ethereum so cool
    // they are a special type of function that can receive Ether
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId] = zombies[_zombieId].level.add(1);
    }

    // withdraw function
    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }

    // function that allows us as the owner of the contract to set the levelUpFee
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // changing name of your zombie if level > 2
    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) ownerOf(_zombieId){
        zombies[_zombieId].name = _newName;
    }

    // changing dna of your zombie if level > 20
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) ownerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    // pure tells us that not only does the function not save any data to the blockchain, but it also doesn't read any data from the blockchain

    // method to view a user's entire zombie army
    // this function will only need to read data from the blockchain, so we can make it a View function --> View functions don't cost gas when they're called externally by a user
    // because view functions don't actually change anything on the blockchain (no data will be saved/changed)

    // note: If a view function is called internally from another function in the same contract that is not a view function, it will still cost gas.
    // this is because the other function creates a transaction on Ethereum, and will still need to be verified from every node.
    // so view functions are only free when they're called externally.

    function getZombiesByOwner(address _owner) external view returns(uint[]) {
        // can use the memory keyword with arrays to create a new array inside a function without needing to write anything to storage

        // memory arrays must be created with a length argument
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if( zombieToOwner[i] == _owner ) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}