// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract lottery
{
    address public Manager; //creating a manager
    address payable[] public participants ; //setting array for many participants

    constructor()
    {
        Manager = msg.sender; //global variable
    }

     receive() external payable //It will receive money from participants
     {
         require(msg.value == 1 ether);
         participants.push(payable(msg.sender));
     }
  
    function getBalance() public view returns(uint)
    {
        //it will show the total balance Manager has received
        require(msg.sender == Manager);
        return address(this).balance;
    }

    function random() public view returns(uint)
    {
        //It generates random values and It's not usually recommended to use such things
        return uint(keccak256(abi.encodePacked(block.difficulty , block.timestamp , participants.length)));
    }

   function selectWinner() public 
   {
     require(msg.sender == Manager);
     require(participants.length >= 2);
     uint r = random();
     address payable winner;
     uint index = r % participants.length;
     winner = participants[index];
     winner.transfer(getBalance());
     participants = new address payable[](0);
   }

}