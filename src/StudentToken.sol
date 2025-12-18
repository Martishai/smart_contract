// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StudentToken
 * @author Student
 * @notice ERC-20 simple et pédagogique
 */
contract StudentToken {

    string public name = "Student Token";
    string public symbol = "STU";
    uint8 public decimals = 18;

    uint public totalSupply;
    address public owner;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowances;
    mapping(address => bool) public blocked;

    // ===== EVENTS =====
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Blocked(address indexed user);
    event Unblocked(address indexed user);

    // ===== MODIFIERS =====
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notBlocked(address user) {
        require(!blocked[user], "Account blocked");
        _;
    }

    // ===== CONSTRUCTOR =====
    constructor(uint initialSupply) {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    // ===== READ FUNCTIONS =====
    function balanceOf(address user) public view returns (uint) {
        return balances[user];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint) {
        return allowances[tokenOwner][spender];
    }

    // ===== TRANSFER LOGIC =====
    function transfer(address to, uint amount)
        public
        notBlocked(msg.sender)
        notBlocked(to)
        returns (bool)
    {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint amount)
        public
        notBlocked(msg.sender)
        returns (bool)
    {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount)
        public
        notBlocked(from)
        notBlocked(to)
        returns (bool)
    {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance too low");

        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // ===== TOKEN CREATION / DESTRUCTION =====
    function mint(address to, uint amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint amount) public notBlocked(msg.sender) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    function _mint(address to, uint amount) internal {
        balances[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    // ===== ACCOUNT MANAGEMENT =====
    function blockAccount(address user) public onlyOwner {
        blocked[user] = true;
        emit Blocked(user);
    }

    function unblockAccount(address user) public onlyOwner {
        blocked[user] = false;
        emit Unblocked(user);
    }
}

