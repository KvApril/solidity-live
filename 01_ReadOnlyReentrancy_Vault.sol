// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: `withdraw` is reentrancy-vulnerable — fix it.
// Senior follow-up: `pricePerShare()` is read by OTHER protocols as an
// oracle. Make sure it can't return a manipulated value mid-withdrawal
// (read-only reentrancy). Don't change any function signatures.

contract Vault {
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    function deposit() external payable {
        require(msg.value > 0, "zero");
        uint256 minted = totalShares == 0
            ? msg.value
            : (msg.value * totalShares) / (address(this).balance - msg.value);
        shares[msg.sender] += minted;
        totalShares += minted;
    }

    function withdraw(uint256 shareAmount) external {
        require(shares[msg.sender] >= shareAmount, "insufficient");
        uint256 ethOut = (shareAmount * address(this).balance) / totalShares;

        (bool ok, ) = msg.sender.call{value: ethOut}("");
        require(ok, "send failed");

        shares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;
    }

    // Used by other protocols as a price oracle.
    function pricePerShare() external view returns (uint256) {
        if (totalShares == 0) return 1e18;
        return (address(this).balance * 1e18) / totalShares;
    }
}
