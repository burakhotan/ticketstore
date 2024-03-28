// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

contract TicketStore{
    uint256 ticketPrice = 0.01 ether;
    uint256 ticketPointPrice = 1000;
    uint256 pointsPerTicket = 100;
    address owner;
    mapping (address=>uint256) public ticketHolders;
    mapping (address => uint256) public pointsBalance;
    
    constructor(){
        owner = msg.sender;
    }

    function buyTickets(address _user, uint256 _amount) payable public {
        require(msg.value >=ticketPrice* _amount);
        addTickets(_user, _amount);

        uint256 pointsEarned = _amount * pointsPerTicket;
        pointsBalance[msg.sender] += pointsEarned;
    }

    function useTickets(uint256 _amount) public {
        subTickets(msg.sender, _amount);
    }


    function addTickets(address _user, uint256 _amount) internal {
        ticketHolders[_user] = ticketHolders[_user] + _amount;
    }

    function subTickets(address _user, uint256 _amount) internal {
        require(ticketHolders[_user]>= _amount,"You don't have enough tickets.");
        ticketHolders[_user] = ticketHolders[_user] - _amount;
    }

    function withdraw() public {
        require(msg.sender == owner, "You are not the owner.");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success);
    }
    function applyDiscount(uint256 _discountPercentage) public {
        require(msg.sender == owner, "You are not the owner.");
        require(_discountPercentage <= 100, "Invalid discount percentage");
        ticketPrice = ticketPrice - (ticketPrice * _discountPercentage / 100);
    }
    function cancelDiscount() public {
        require(msg.sender == owner, "You are not the owner.");
        ticketPrice = 0.01 ether;
    }
    function redeemPoints() public {
        require(pointsBalance[msg.sender] >= ticketPointPrice, "Insufficient points.");
        pointsBalance[msg.sender] = pointsBalance[msg.sender] - ticketPointPrice;
        addTickets(msg.sender, 1);
    }

}