// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ticket is ERC721, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;
    uint256 ticketPrice = 0.01 ether;
    uint256 ticketPointPrice = 1000;
    uint256 pointsPerTicket = 100;
    mapping (address=>uint256) public ticketHolders;
    mapping (address => uint256) public pointsBalance;

    constructor(address initialOwner)
        ERC721("Ticket", "TCK")
        Ownable(initialOwner)
    {}

    function safeMint(address to) internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function buyTickets(address _user, uint256 _amount) payable public {
        require(msg.value >=ticketPrice* _amount);
        for (uint256 i = 1; i <= _amount; i++) {
            safeMint(msg.sender);
        }
        addTickets(_user, _amount);

        uint256 pointsEarned = _amount * pointsPerTicket;
        pointsBalance[msg.sender] += pointsEarned;
    }

    function useTickets(uint256 _tokenId) public {
        require(_ownerOf(_tokenId) ==msg.sender,"You are not the owner of this ticket");
        _burn(_tokenId);
        subTickets(msg.sender,1);
    }

    function addTickets(address _user, uint256 _amount) internal {
        ticketHolders[_user] = ticketHolders[_user] + _amount;
    }

    function subTickets(address _user, uint256 _amount) internal {
        require(ticketHolders[_user]>= _amount,"You don't have enough tickets.");
        ticketHolders[_user] = ticketHolders[_user] - _amount;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success);
    }
    function applyDiscount(uint256 _discountPercentage) public onlyOwner {
        require(_discountPercentage <= 100, "Invalid discount percentage");
        ticketPrice = ticketPrice - (ticketPrice * _discountPercentage / 100);
    }
    function cancelDiscount() public onlyOwner {
        ticketPrice = 0.01 ether;
    }
    function redeemPoints() public {
        require(pointsBalance[msg.sender] >= ticketPointPrice, "Insufficient points.");
        pointsBalance[msg.sender] = pointsBalance[msg.sender] - ticketPointPrice;
        safeMint(msg.sender);
        addTickets(msg.sender, 1);
    }
}