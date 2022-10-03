// NOTE \\ Delegate Call is a method to make Upgradable contracts.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A but names of variables can be different, 
    // Since solidity look for the slots in storage not the name.
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

// In contract A, we are using the function of contract B to make new logics with it. 
// Think of "delegateCalls" as the broker, Who helps contract A to borrow function from contract B
// NOTE \\ Now the values of this function will be stored in contract A's storage not in contract B

contract A {
    uint public newNum;
    address public newSender;
    uint public newValue;

    function setVars(address _contract, uint _num) public payable {
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}

