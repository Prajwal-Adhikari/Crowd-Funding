//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding{
    //Declaring all the variables to be used.
    mapping(address => uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public raisedAmount;
    uint public deadline;
    uint public target;
    uint public noOfContributors;

    struct Request{
        string detail;
        address payable receipent;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;

    }
    mapping(uint => Request) public requests;
    uint public numRequests;
    //Constructor to initialize the basic variables at the time of deployment
       constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp+_deadline;
        minContribution = 100 wei;
        manager = msg.sender;

    }
    //Contributors part
    //send ether
    function sendEther() public payable {
        require(block.timestamp < deadline,"Deadline has passed");        //Contribution is valid within deadline.

        require(msg.value >= minContribution,"Minimum contribution is not met.");   //Receive contribution with the minimum contribution of 100 wei threshold.

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    //function to check contract balance
    function checkBalance() public view returns(uint){
        return address(this).balance;
    }
    //function to refund donations
    //refund is only valid if target is not met and deadline has passed.
    function refund() public{
        require(block.timestamp > deadline && raisedAmount < target,"You are not eligible to get refund.");
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        //After refunding make address's contribution zero
        contributors[msg.sender] = 0;
    } 
    //end of contributors part

    //Manager part
    modifier onlyManager(){
        require(msg.sender == manager,"Only manager can call this function");
        _;
    }

    function createRequest(string memory _detail, address payable _receipent, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.detail = _detail;
        newRequest.receipent = _receipent;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;


    }

}