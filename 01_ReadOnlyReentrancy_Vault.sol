// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: `withdraw` is reentrancy-vulnerable — fix it.
// Senior follow-up: `pricePerShare()` is read by OTHER protocols as an
// oracle. Make sure it can't return a manipulated value mid-withdrawal
// (read-only reentrancy). Don't change any function signatures.

contract Vault {
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    // 重入锁
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status = NOT_ENTERED;

    modifier nonReentrant() {
        require(_status != ENTERED, "reentrant");
        _status = ENTERED;
        _;
        _status = NOT_ENTERED;
    }

    function deposit() external payable {
        require(msg.value > 0, "zero");
        uint256 minted = totalShares == 0
            ? msg.value
            : (msg.value * totalShares) / (address(this).balance - msg.value);
        shares[msg.sender] += minted;
        totalShares += minted;
    }

    function withdraw(uint256 shareAmount) external nonReentrant {
        require(shares[msg.sender] >= shareAmount, "insufficient");
        uint256 ethOut = (shareAmount * address(this).balance) / totalShares;

        // Effects: 先更新状态
        shares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;

        // Interactions: 后转账
        (bool ok, ) = msg.sender.call{value: ethOut}("");
        require(ok, "send failed");
    }

    // 只读重入防护：withdraw 执行期间（_status == ENTERED）不允许读价格
    function pricePerShare() external view returns (uint256) {
        require(_status != ENTERED, "reentrancy: price unavailable");
        if (totalShares == 0) return 1e18;
        return (address(this).balance * 1e18) / totalShares;
    }
}
