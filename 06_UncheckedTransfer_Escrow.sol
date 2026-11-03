// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: some ERC20s return `false` instead of reverting on
// failure. As written, a failed transferFrom still credits the deposit —
// free money. Fix both functions so a false return reverts everything.
// Follow-up question: what breaks with tokens that return NO bool at
// all (USDT), and how does SafeERC20 handle it?
// Don't change function signatures.

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Escrow {
    IERC20 public immutable token;
    mapping(address => uint256) public balance;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount); // BUG: return ignored
        balance[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(balance[msg.sender] >= amount, "insufficient");
        balance[msg.sender] -= amount;
        token.transfer(msg.sender, amount); // BUG: return ignored
    }
}
