// SPDX-License-Identifier: GPL-3.0

// So why do we care about all this encoding stuff?

// In order to call a function using only the data field of call, we need to encode:
// The function name
// The parameters we want to add
// Down to the binary level

// Now each contract assigns a function ID to each function. This is known as the "function selector".
// The "function selector" is the first 4 bytes of the function signature. 
// The "function signature" is a string that defines the function name & parameters.

// NOTE \ For Example:-> // 1. Function Selector = 0xa9059abb (bytes is a pair of 2 hexadecimal characters)
                         // 2. Function Signature = "transfer(address, uint256)"

// With the help of Function Selector we can call that Function.

// Let's look at this


pragma solidity ^0.8.0;

contract CallAnything{
    address public s_someAddress;
    uint256 public s_amount;

    function transfer(address someAddress, uint256 amount) public {
        s_someAddress = someAddress;
        s_amount = amount;
    }

/**
 * @dev Getting the Function Selector.
 * @dev The keccak256 (SHA-3 family) algorithm computes the hash of an input to a fixed length output. 
 * The input can be a variable length string or number, but the result will always be a fixed bytes32 data type. 
 * It is a one-way cryptographic hash function, which cannot be decoded in reverse. 
 * This consists of 64 characters (letters and numbers) that can be expressed as hexadecimal numbers.
 */
    function getSelectorOne() public pure returns(bytes4 selector) {
        selector = bytes4(keccak256(bytes("transfer(address,uint256)")));
    } // returns this signature = "0xa9059cbb"

    /**
     * @dev Encoding Function Parameters.
     * @dev "encodeWithSelector()" = Is a way to encode parameters with the selector data.
     * @dev We will put the result of this function in "data" field of our txn in order to call the "transfer" function from anywhere
     */
    function getDataToCallTransfer(address someAddress, uint256 amount) public pure returns (bytes memory){
        return abi.encodeWithSelector(getSelectorOne(), someAddress, amount);
    }

     /**
     * @dev This Function calls the Transfer function Directly from low level with binary data.
     * @dev In this way we can call any function from any address without the need of ABI file 
     *   HOW? 
     * 1. Go to the etherscan and search for the contract address you want
     * 2. Then go to Transaction Details and see the "Input Data".
     * 3. There you will get to see the "function signature" and "methodId" which is basically a "function selector" in bytes4
     * 
     * @dev So, This is how, you can with just the "Address" , "Function Signature" and "Function Selector" of the contract. You can call the specific function
     */
    function callTransferFunctionWithBinary(address someAddress, uint256 amount) public returns(bytes4, bool){
        (bool success, bytes memory returnData) = address(this).call(
                                                  getDataToCallTransfer(someAddress, amount)
                                                //   abi.encodeWithSelector(getSelectorOne(), someAddress, amount)
                                                  );
        return (bytes4(returnData), success);
    }

    /**
     * @dev We can also do "encodeWithSignature" instead of selector
     */
    function callTransferFunctionWithBinaryBySignature(address someAddress, uint256 amount) public returns(bytes4, bool){
        (bool success, bytes memory returnData) = address(this).call(
                                                  abi.encodeWithSignature("transfer(address,uint256)", someAddress, amount)
                                                  );
        return (bytes4(returnData), success);
    }

    // NOTE \ We can also get a function selector from data sent into the call
    function getSelectorTwo() public view returns (bytes4 selector) {
        bytes memory functionCallData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            address(this),
            123
        );
        selector = bytes4(
            bytes.concat(
                functionCallData[0],
                functionCallData[1],
                functionCallData[2],
                functionCallData[3]
            )
        );
    }

    // Another way to get data (hard coded)
    function getCallData() public view returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", address(this), 123);
    }

    // Pass this:
    // 0xa9059cbb000000000000000000000000d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b000000000000000000000000000000000000000000000000000000000000007b
    // This is output of `getCallData()`
    // This is another low level way to get function selector using assembly
    // You can actually write code that resembles the opcodes using the assembly keyword!
    // This in-line assembly is called "Yul"
    // It's a best practice to use it as little as possible - only when you need to do something very VERY specific
    function getSelectorThree(bytes calldata functionCallData)
        public
        pure
        returns (bytes4 selector)
    {
        // offset is a special attribute of calldata
        assembly {
            selector := calldataload(functionCallData.offset)
        }
    }

    // Another way to get your selector with the "this" keyword
    function getSelectorFour() public pure returns (bytes4 selector) {
        return this.transfer.selector;
    }

    // Just a function that gets the signature
    function getSignatureOne() public pure returns (string memory) {
        return "transfer(address,uint256)";
    }
}

// \\ // \\ // \\ // \\ // SECTION = New Contract \\ // \\ // \\ // \\ // \\ 
contract CallFunctionWithoutContract {
    address public s_selectorsAndSignaturesAddress;

    constructor(address selectorsAndSignaturesAddress) {
        s_selectorsAndSignaturesAddress = selectorsAndSignaturesAddress;
    }

    // pass in 0xa9059cbb000000000000000000000000d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b000000000000000000000000000000000000000000000000000000000000007b
    // you could use this to change state
    function callFunctionDirectly(bytes calldata callData) public returns (bytes4, bool) {
        (bool success, bytes memory returnData) = s_selectorsAndSignaturesAddress.call(
            abi.encodeWithSignature("getSelectorThree(bytes)", callData)
        );
        return (bytes4(returnData), success);
    }

    // with a staticcall, we can have this be a view function!
    function staticCallFunctionDirectly() public view returns (bytes4, bool) {
        (bool success, bytes memory returnData) = s_selectorsAndSignaturesAddress.staticcall(
            abi.encodeWithSignature("getSelectorOne()")
        );
        return (bytes4(returnData), success);
    }

    function callTransferFunctionDirectly(address someAddress, uint256 amount)
        public
        returns (bytes4, bool)
    {
        (bool success, bytes memory returnData) = s_selectorsAndSignaturesAddress.call(
            abi.encodeWithSignature("transfer(address,uint256)", someAddress, amount)
        );
        return (bytes4(returnData), success);
    }
}
