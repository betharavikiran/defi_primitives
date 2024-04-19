pragma solidity ^0.8.0;

contract LiquidityPoolTokenized {
    uint256 public totalSupply;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;

    event Deposit(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be positive");
        totalSupply += msg.value;
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Withdraw amount must be positive");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function approve(address spender, uint256 value) public {
        require(spender != address(0), "Invalid spender address");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transfer(address recipient, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Transfer amount must be positive");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public {
        require(balances[sender] >= amount, "Insufficient sender balance");
        require(allowance[sender][msg.sender] >= amount, "Insufficient allowance");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Transfer amount must be positive");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
    }
}