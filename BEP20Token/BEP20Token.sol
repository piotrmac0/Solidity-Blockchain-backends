//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;


 contract Token {
    mapping(address => uint) public balances;
    // mapping for allowance to transfer token for smart contract
    mapping(address => mapping(address=>uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18; // 1 token = 1*10**18
    string public name = "Meme Token";
    string public symbol = "MEME";
    uint public decimals = 18; //smallest token fractino can be tranferred, 1 token = 1*10**18

    event Transfer(address indexed from, address indexed to, uint value); //indexed means that we can fetching data from it outside blockchain
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    //transfering and updating balances of buyer and supply
    // also here value of 1 token = 1*10**18
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        // updating balance of buyer
        balances[to] += value;
        // updating balance of contract/supply
        balances[msg.sender] -= value;
        // emit Transfer event
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    //setting allowance 
    function approve(address spender, uint value) public returns(bool) {
        // nested mapping, spender can transfer 'value' token belonging to msg sender
        allowance[msg.sender][spender] = value; 
        emit Approval(msg.sender, spender, value);
        return true; 
    }

 }