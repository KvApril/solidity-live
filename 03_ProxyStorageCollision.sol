// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TASK: Proxy delegatecalls into Implementation, so both share
// the PROXY's storage — and both declare variables at slots 0/1, so
// `admin`/`implementation` collide with `owner`/`totalSupply`.
// Fix Proxy ONLY: store admin + implementation at fixed keccak256-derived
// slots (EIP-1967 style) read/written via assembly. Keep `upgradeTo`
// admin-only; keep the fallback bubbling returndata and reverts.

contract Implementation {
    address public owner;       // slot 0
    uint256 public totalSupply; // slot 1

    function initialize(address _owner) external {
        owner = _owner;
    }

    function mint(uint256 amount) external {
        require(msg.sender == owner, "not owner");
        totalSupply += amount;
    }
}

contract Proxy {
    address public admin;          // BUG: slot 0, collides with owner
    address public implementation; // BUG: slot 1, collides with totalSupply

    constructor(address impl) {
        admin = msg.sender;
        implementation = impl;
    }

    function upgradeTo(address impl) external {
        require(msg.sender == admin, "not admin");
        implementation = impl;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "no impl");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let ok := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch ok
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
