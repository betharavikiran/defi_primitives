// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import { ERC20 } from "contracts/ERC20.sol";

contract Escrow {
    // Define state variables
    ERC20 public token; // Payment against delivery of goods
    address public buyer; // Buyer of the Asset
    address public seller; // Seller of the Asset
    uint256 public value;  // Value of gooding being purchased
    uint256 public deadline; // Time line with in which the transaction should be completed.

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
    // The asset value and the Native token value is considered as equal for simplification
    function deposit(uint value_) public {
        require(buyer == address(0), "Deposit already made");
        // tokens are pulled from Buyer into this contract
        token.transferFrom(buyer, address(this), value_);
        buyer = msg.sender;
    }

    // Function for the seller to confirm that the goods have been delivered
    function acceptTransaction() public {
        require(seller == address(0), "Delivery already confirmed");
        require(block.timestamp <= deadline, "Deadline has passed");
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
        require(msg.sender == buyer, "Only the Buyer can initiate a refund");
        payable (buyer).transfer(value);
    }
}