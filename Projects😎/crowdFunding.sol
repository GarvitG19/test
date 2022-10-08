// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract CrowdFunding
{
    mapping(address=> uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public target; 
    uint public deadline;
    uint public raisedAmount;
    uint public noOfContributors;


    //2nd part started
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

 mapping(uint=> Request)  public requests;
uint public numRequests;


// Again started first part
    constructor(uint _target , uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline ; //This deadline should be in seconds 
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable{
          require(deadline > block.timestamp ,"Deadline has passed");
          require(msg.value >= minContribution , "Min Contribution is 100 wei");
   
      if(contributors[msg.sender] == 0){
          noOfContributors++; //This function sees that a contributor has contributed only ones 
          //if its address matches with this than it is not counted twice in number;
      }
          contributors[msg.sender]+= msg.value; //increase the contributors[msg.sender] value by his contribution amount
          raisedAmount+=msg.value;
    }

    function ContractBalance() public view returns(uint) {
         return address(this).balance;
    }

     function Refund() public {
    //    require(block.timestamp > deadline);
    //    require(noOfContributors < target);
         require(block.timestamp > deadline && raisedAmount < target);
         require(contributors[msg.sender] > 0);

         address payable user = payable(msg.sender);
         user.transfer(contributors[msg.sender]);
         contributors[msg.sender] = 0;
     }


// Second part started again
modifier onlyManager() {
    require(msg.sender == manager , "Only accessible by manager");
    _;
}

function createRequest(string memory _description , address payable _recipient , uint _value) public onlyManager{
    Request storage newRequest = requests[numRequests];
    numRequests++;
    newRequest.description = _description;
    newRequest.recipient = _recipient;
    newRequest.value = _value;
    newRequest.completed = false;
    newRequest.noOfVoters = 0;
}

function voteRequest(uint _requestNo) public {
    require(contributors[msg.sender] > 0 , "You must be a contributor ..");
    Request storage thisRequest = requests[_requestNo];
    require(thisRequest.voters[msg.sender] == false , 'You have already voted');
    thisRequest.voters[msg.sender] = true;
    thisRequest.noOfVoters++;
}

function makePayment(uint _requestNo) public onlyManager{
    require(raisedAmount >= target);
    Request storage thisRequest = requests[_requestNo];
    require(thisRequest.completed == false , 'Request has already been completed');
    require(thisRequest.noOfVoters > noOfContributors/2 , 'Majority Denied');
    thisRequest.recipient.transfer(thisRequest.value);
    thisRequest.completed = true ;
}


}