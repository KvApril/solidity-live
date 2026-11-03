// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: proxy-logic pattern, so the constructor can't set
// per-proxy state — `initialize` does. But anyone can call it, any
// number of times, and become owner. Make it callable exactly once.
// Don't change function signatures.

contract LogicVault {
    address public owner;

    function initialize(address _owner) external {
        // BUG: no guard — anyone can (re)initialize and take over
        require(_owner != address(0), "zero");
        owner = _owner;
    }

    function sweep(address payable to) external {
        require(msg.sender == owner, "not owner");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "send failed");
    }

    receive() external payable {}
}
