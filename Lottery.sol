
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


contract LotterySystem{

    address public lotteryHost;
    address payable[] participants;
    uint private  hostCommission = 2 ether;
    string private errorMessage = "Only the lottery host can call this function";
    uint private  lotterAmount = 2 ether;

    constructor(){
        lotteryHost = msg.sender;
    }

    function getHostCommission() public view returns(uint){
        require(msg.sender == lotteryHost);
        return  hostCommission;
    }

    function setLotterySystem(uint amount) public {
        require(msg.sender == lotteryHost);
        lotterAmount = amount * 1 ether;
    }

    //receive amount from users 
    receive() external payable 
    {    
        //allow only 10 participants
        require(msg.value == lotterAmount); 
        require(participants.length == 10);
        participants.push(payable (msg.sender));
    }

    function setHostCommission(uint commission) public {
        require(msg.sender == lotteryHost, errorMessage);
        hostCommission = commission * 1 ether;
    }

    function getBalance() public view returns(uint){
        require(msg.sender == lotteryHost, errorMessage);
        return address(this).balance;
    }

    function getRandomNumber() private  view returns(uint){
        return uint (keccak256(abi.encodePacked (msg.sender, block.timestamp, participants.length)));
    }

    function setWinner() public {
        require(participants.length > 1, "participanrts are not enough, at least 2 are allowed");
        require(msg.sender == lotteryHost, errorMessage);
        address payable winner;
        uint winnerIndex = getRandomNumber() % participants.length;
        winner = participants[winnerIndex];
        winner.transfer(getWinnerAmount());
        participants = new address payable[](0);
    }

    function getWinnerAmount() private  view returns(uint) {
       return (getBalance() - hostCommission);
    }
}