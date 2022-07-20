//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract DzikToken is ERC20Interface {
    string public name = "DZIK";
    string public symbol = "DZK";
    uint256 public decimals = 0;
    uint256 public override totalSupply; //override cause totalSupply was definied in ERC20Interface

    address public founder;
    mapping(address => uint256) public balances; // balances[0x1234..] = 100;

    mapping(address => mapping(address => uint256)) allowed; //accounts allowed to withdraw from main token account, first address is a token holder

    // 0x1111 (owner) allows 0x2222 (spender) -- 100 tokens
    // mapping'll be: allowed[0x1111][0x2222] = 100;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    //virtual means that function can change their behavior in another contract by overwriting
    function transfer(address to, uint256 tokens)
        public
        virtual
        override
        returns (bool success)
    {
        //require(balances[msg.sender] => tokens);

        balances[to] += tokens; //balances of recipent after sending tokens
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256)
    {
        //function'll return how many tokens owner allowed the spender to withdraw
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        //set by the owner, the aprroval for allowance to withdraw that X tokens amount
        require(balances[msg.sender] >= 0);
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        //this f called by spender, allowed to transfer tokens from owner to spender the amount set in the allowance function
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);

        balances[from] -= tokens; //balances of owner after withdraw
        balances[to] += tokens;
        allowed[from][to] -= tokens; //allowed mapping variable of

        emit Transfer(from, to, tokens);

        return true;
    }
}
