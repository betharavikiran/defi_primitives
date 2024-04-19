// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import { ERC20 } from "contracts/ERC20.sol";


contract Escrow {
    // Define state variables
    ERC20 public token;
    address public buyer;
    address public seller;
    uint256 public value;
    uint256 public deadline;

    // Event to signal the completion of a trade
    event TradeCompleted(
        address indexed _buyer,
        address indexed _seller,
        uint256 _value
    );

    // Constructor function
    constructor(ERC20 _token, uint256 _value, uint256 _deadline) {
        token = _token;
        value = _value;
        deadline = _deadline;
    }

    // Function to deposit funds into the escrow
    function deposit() public payable {
        require(msg.value == value, "Incorrect deposit amount");
        require(buyer == address(0), "Deposit already made");
        buyer = msg.sender;
    }

    // Function for the seller to confirm that the goods have been delivered
    function confirmDelivery() public {
        require(seller == address(0), "Delivery already confirmed");
        require(msg.sender == buyer, "Only the buyer can confirm delivery");
        seller = msg.sender;
    }

    // Function for the buyer to release the funds to the seller
    function releaseFunds() public {
        require(buyer != address(0), "No deposit made");
        require(seller != address(0), "Delivery not confirmed");
        require(msg.sender == buyer, "Only the buyer can release funds");
        require(block.timestamp >= deadline, "Deadline has not passed");
        token.transferFrom(buyer, seller, value);
        emit TradeCompleted(buyer, seller, value);
    }

    // Function to refund the buyer in case of a failed trade
    function refund() public {
        require(buyer != address(0), "No deposit made");
        require(seller == address(0), "Delivery not confirmed");
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(msg.sender == seller, "Only the seller can initiate a refund");
        payable (buyer).transfer(value);
    }
}