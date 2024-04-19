pragma solidity ^0.8.0;

contract LiquidityPoolSimple {
    uint256 public totalSupply;
    mapping (address => uint256) public balances;

    function deposit(uint256 amount) public payable {
        require(msg.value == amount, "Incorrect deposit amount");
        totalSupply += amount;
        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}