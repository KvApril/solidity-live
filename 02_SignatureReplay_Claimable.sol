// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: `owner` signs (account, amount) off-chain; `claim`
// pays out if the signature checks. As written one signature can be
// replayed: repeatedly, on other chains, on other deployments.
// Make each signature single-use, chain-bound, and contract-bound —
// WITHOUT changing `claim`'s signature (bind it in the hash).

contract Claimable {
    address public immutable owner;

    constructor(address _owner) payable {
        owner = _owner;
    }

    function claim(address account, uint256 amount, bytes calldata sig) external {
        bytes32 h = keccak256(abi.encodePacked(account, amount)); // BUG: replayable
        h = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", h));
        require(_recover(h, sig) == owner, "bad sig");

        (bool ok, ) = account.call{value: amount}("");
        require(ok, "send failed");
    }

    function _recover(bytes32 h, bytes calldata sig) internal pure returns (address) {
        require(sig.length == 65, "bad length");
        bytes32 r; bytes32 s; uint8 v;
        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }
        return ecrecover(h, v, r, s);
    }

    receive() external payable {}
}
