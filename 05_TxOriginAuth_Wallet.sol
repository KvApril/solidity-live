// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: only the owner should move funds out, but the auth
// check is exploitable if the owner ever calls into a malicious
// contract (phishing). Name the bug and fix both functions.
// Don't change function signatures.

contract Wallet {
    address public owner;

    // 重入锁（withdraw 会向任意地址 call，属外部调用）
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status = NOT_ENTERED;

    modifier nonReentrant() {
        require(_status != ENTERED, "reentrant");
        _status = ENTERED;
        _;
        _status = NOT_ENTERED;
    }

    constructor() payable {
        owner = msg.sender;
    }

    function withdraw(address payable to, uint256 amount) external nonReentrant {
        require(msg.sender == owner, "not owner");   // 修复：msg.sender 鉴权
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "not owner");   // 修复：msg.sender 鉴权
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    receive() external payable {}
}
