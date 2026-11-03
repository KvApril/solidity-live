// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: only the owner should move funds out, but the auth
// check is exploitable if the owner ever calls into a malicious
// contract (phishing). Name the bug and fix both functions.
// Don't change function signatures.

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function withdraw(address payable to, uint256 amount) external {
        require(tx.origin == owner, "not owner"); // BUG
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }

    function transferOwnership(address newOwner) external {
        require(tx.origin == owner, "not owner"); // BUG
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    receive() external payable {}
}
