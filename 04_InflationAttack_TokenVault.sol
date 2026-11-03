// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: classic first-depositor inflation attack.
// Attacker deposits 1 wei (gets 1 share), then transfers tokens DIRECTLY
// to the vault to inflate share price; the next depositor's minted
// shares round down to 0 while the attacker owns the whole pot.
// Fix: permanently lock a minimum share amount on the first deposit, and
// make rounding always favor the vault. Don't change function signatures.

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenVault {
    IERC20 public immutable token;
    uint256 public totalShares;
    mapping(address => uint256) public shares;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external returns (uint256 minted) {
        require(amount > 0, "zero");
        uint256 balBefore = token.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), amount), "tf failed");

        // BUG: no floor on first deposit + donation-manipulable balance
        minted = totalShares == 0 ? amount : (amount * totalShares) / balBefore;
        require(minted > 0, "zero shares");

        shares[msg.sender] += minted;
        totalShares += minted;
    }

    function withdraw(uint256 shareAmount) external returns (uint256 amountOut) {
        require(shares[msg.sender] >= shareAmount, "insufficient");
        amountOut = (shareAmount * token.balanceOf(address(this))) / totalShares;

        shares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;
        require(token.transfer(msg.sender, amountOut), "t failed");
    }
}
