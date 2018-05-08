pragma solidity ^0.4.19;
import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper {
    uint randNonce = 0;
    uint attackVictoryProbability = 70;
    // not safe (better oracles)
    function randMod(uint _modulus) internal returns (uint) {
        randNonce = randNonce.add(1);
        return uint(keccak256(now, msg.sender, randNonce))% _modulus;
    }
    // Our zombie battles will work as follows:

    // You choose one of your zombies, and choose an opponent's zombie to attack.
    // If you're the attacking zombie, you will have a 70% chance of winning. The defending zombie will have a 30% chance of winning.
    // All zombies (attacking and defending) will have a winCount and a lossCount that will increment depending on the outcome of the battle.
    // If the attacking zombie wins, it levels up and spawns a new zombie.
    // If it loses, nothing happens (except its lossCount incrementing).
    //Whether it wins or loses, the attacking zombie's cooldown time will be triggered.
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        // get a storage pointer to both zombies so we can more easily interact with them
        uint rand = randMod(100);
        if(rand <= attackVictoryProbability) {
            // win situation
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            // lose
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            // the zombie can only attack once per day
            _triggerCooldown(myZombie);
        }
    }
}
