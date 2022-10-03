// SPDX-License-Identifier: MIT

// NOTE: The most important thing You'll get know from this Tutorial is that, Always check-
// 1. If a contract is upgradable?
// 2. If Yes, Then who and specially How many develpers have the key to change the logic of underlying contract.
// 3. If One person have all the rights to change, Then things are really messy. Becoz he can change the whole logic anytime and user's will be secured.
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/Proxy.sol";

// We're importing a proxy contract from openzeppelin to fasciliate our work. 
// OpenZeppelin's proxy contract contains something called "assembly" or "yul".
// What is Yul? => It's a very low level intermidate language to write code close to oopcodes. 
// It is used to write "inline assembly" in solidity.


// To work with proxy, we don't wanna have anything in storage, becoz if we delegate call and that delegate call will change up some storage, we secured up our contract
// Although, We still have to store this implementation address somewhere in storage, so we can call it.
// That's why Ethereum have "EIP-1967: Standard Proxy Storage Slots". 
// This EIP will "standardise where proxies store the address of the logic contract they delegate to, as well as other proxy-specific information.


contract SmallProxy is Proxy {
    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc; // This location slot will be used for storing "implementation Address"

    /**
     * @dev It will take the address of the contract where we wanna do delegateCall.
    */
    function setImplementation(address newImplementation) public {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _implementation() internal view override returns (address implementationAddress) {
        assembly {
            implementationAddress := sload(_IMPLEMENTATION_SLOT)
        }
    }

    // helper function to get the btyes data of "setValue + valueWeGive".
    function getDataToTransact(uint256 numberToUpdate) public pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", numberToUpdate);
    }

    // Now after getting the data solidity will understand that this data is a function which I have to call.
    // But When he look for that function in this SmallProxy contract, 
    // he didn't find anything and then he runs the "delegateCall" function in OpenZeppelin Proxy contract, 
    // Which will call the "ImplementationA" contract and Then store the value of setValue in smallProxy contract.

    // function to read the storage of SmallProxy.
    function readStorage() public view returns (uint256 valueAtStorageSlotZero) {
        assembly {
            valueAtStorageSlotZero := sload(0)
        }
    }
}

// NOTE: Now when I put the address of ImplementationA in "setImplementation" function and add a value in "getDataToTransact",
// and after getting the bytes data from "getDataToTransact", When I put it in "callData" input area in remix and click "Transact"
// The storage of SmallProxy will get updated. and We can see the value from the function "readStorage"

// QUESTION \\ So, the question is how we're gonna use this method to upgrade our contract?
// ANSWER \\ See the contract "ImplementationB", You will notice that we indeed updated the setValue function. 
// and Now If we repeat the above samllProxy Process with the same value, The readStorage function will return NewValue.


// Anytime anyone calls the SmallProxy contract then smallProxy will delegate call the ImplementationA contract and store the value in smallproxy storage
contract ImplementationA {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue;
    }
}

contract ImplementationB {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue + 2;
    }
}



// SECTION - 
// Below code shows us how we create a new contract to still user's money with the help of proxy
// So, That's why you should be aware of this type of tactics.

// In this contract user's can withdraw their money.
contract takeMoneyFromUsers {
     mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// In this contract we are withdrawing all the money deposited by user's in protocol address.
contract stillMoneyFromUsers {   

    function deposit() public payable {
    }

    function withdraw(address payable _to) public payable{
        (bool sent, ) = payable(_to).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
