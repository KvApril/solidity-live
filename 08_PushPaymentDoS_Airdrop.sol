// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: `distribute` pays everyone in one loop. One
// recipient whose receive() reverts bricks the airdrop for ALL, and a
// long list can exceed the block gas limit. Fix by converting to a
// PULL model (each user claims their own allocation) — mind
// checks-effects-interactions in the claim path. You may replace
// `distribute`, but keep `setAllocation` as-is.

contract Airdrop {
    address public immutable owner;
    address[] public recipients;
    mapping(address => uint256) public allocation;

    constructor() payable {
        owner = msg.sender;
    }

    function setAllocation(address user, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        if (allocation[user] == 0 && amount > 0) recipients.push(user);
        allocation[user] = amount;
    }

    // BUG: unbounded push loop; one reverting recipient blocks everyone
    function distribute() external {
        for (uint256 i = 0; i < recipients.length; i++) {
            address to = recipients[i];
            uint256 amount = allocation[to];
            if (amount == 0) continue;

            allocation[to] = 0;
            (bool ok, ) = to.call{value: amount}("");
            require(ok, "send failed");
        }
    }

    receive() external payable {}
}
