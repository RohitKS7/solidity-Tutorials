// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


// For the cheatsheet, check out the docs: https://docs.soliditylang.org/en/v0.8.13/cheatsheet.html?highlight=encodewithsignature

/**
 * @title Encoding
 */
contract Encoding { 

/**
 * @dev abi.encodePacked is a Global Variable to encode the strings in their bytes code.
 * and we are typecasting by wrapping it in string and "bytes -> string" type Change is Valid.
 * @dev From version 0.8.12 we can do this string.concat("String A", "String B") instead of using abi.encodePacked
 */
function combineStrings() public pure returns (string memory){
    return string(abi.encodePacked("My Name", " is Rohit")); // retuns => My Name is Rohit
    // NOTE \ From version 0.8.12+ we can do: string.concat("String A", "String B") instead of abi.encodePacked
}

// \\ // \\ // \\ // \\ // \\ SECTION // \\ // \\ // \\ // \\ // \\  

// When we send a transaction, it is "compiled" down to bytecode and sent in a "data" object of the transaction automatically.
// This bytecode will only be send with "data" object  when we are deploying Smart Contract , not when crypto transactions automatically. But We can put some data by our selfs.
// That data object now governs how future transactions will interact with it.
// For example:  // For example: https://etherscan.io/tx/0x112133a0a74af775234c077c397c8b75850ceb61840b33b23ae06b753da40490

// Now, in order to read and understand these bytes, you need a special reader.
// This is supposed to be a new contract? How can you tell?
// Let's compile this contract in hardhat or remix, and you'll see the the "bytecode" output 

// This bytecode represents exactly the low level computer instructions to make our contract happen.
// These low level instructions are spread out into something called "opcodes".

// An opcode is going to be 2 characters that represents some special instruction (00 => STOP, 01 => ADD), and also optionally has an input

// You can see a list of this here:
// https://www.evm.codes/
// Or here:
// https://github.com/crytic/evm-opcodes

// The opcode reader is sometimes abstractly called the EVM - or the ethereum virtual machine.
// The EVM basically represents all the instructions a computer needs to be able to read.
// ASNWER \ Any language that can compile down to bytecode with these opcodes is considered EVM compatible
// Which is why so many blockchains are able to do this - you just get them to be able to understand the EVM and presto! Solidity smart contracts work on those blockchains.

    // Now, just the binary can be hard to read, so why not press the `assembly` button? You'll get the binary translated into
    // the opcodes and inputs for us!
    // We aren't going to go much deeper into opcodes, but they are important to know to understand how to build more complex apps.

    // How does this relate back to what we are talking about?
    // Well let's look at this encoding stuff

    // In this function, we encode the number one to what it'll look like in binary
    // Or put another way, we ABI encode it.
    function encodeNumber() public pure returns (bytes memory) {
        bytes memory number = abi.encode(1);
        return number;
    }

 // You'd use this to make calls to contracts
    function encodeString() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("some string");
        return someString;
    }
// return => 0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b736f6d6520737472696e67000000000000000000000000000000000000000000

    // NOTE \ encodePacked()
    // This is great if you want to save space and GAS, not good for calling functions.
    // You can sort of think of it as a compressor for the massive bytes object with lots of non-usable Zeros above.
    function encodeStringPacked() public pure returns (bytes memory) {
        bytes memory someString = abi.encodePacked("some string");
        return someString;
    }
// return => 0x736f6d6520737472696e67

// This is just type casting to string
    // It's slightly different from below, and they have different gas costs
    function encodeStringBytes() public pure returns (bytes memory) {
        bytes memory someString = bytes("some string");
        return someString;
    }
// QUESTION \ "difference-between-abi-encodepacked-string-and-bytes-string?"
// ANSWER \ https://forum.openzeppelin.com/t/difference-between-abi-encodepacked-string-and-bytes-string/11837

/**
 * @dev We also have a Global Variable for decoding bytes code into human readable form.
 * That is "abi.decode()" =>  It takes the encodeData and the type in which we wanted to convert the data.
 */
 function decodeString() public pure returns(string memory){
     string memory someString = abi.decode(encodeString(), (string));
     return someString;
 }

/**
 * @dev We can Multi Encode
 */
 function multiEncode() public pure returns(bytes memory){
     bytes memory someString = abi.encode("You are not", " a Good Person");
     return someString;
 }

/**
 * @dev We can Multi Decode
 */
 function multiDecode() public pure returns (string memory, string memory){
     (string memory someString, string memory someOtherString) = abi.decode(multiEncode(), (string, string));
     return (someString, someOtherString);
 }

/**
 * @dev We can concat/combine the values of Multi decode.
 */
  function _concatMultiDecodeValues() public pure returns (string memory){
     (string memory someString, string memory someOtherString) = multiDecode();
     string memory newConcatString = string(abi.encodePacked(someString, someOtherString));
     return newConcatString;
 }

/**
 * @dev We can Multi EncodePacked
 */
 function multiEncodePacked() public pure returns (bytes memory){
     bytes memory someString = abi.encodePacked("Main HOon" , " Naa");
     return someString;
 }

// NOTE \ decoding of "multiEncodePacked()" will not gonna work like this
 function multiDecodePacked() public pure returns ( string memory){
     string memory someString = abi.decode(multiEncodePacked(), (string));
     return someString;
 }

/**
 * @dev We can Decode the Multi EncodePacked
 */
// ANSWER \ It's how we're gonna decode "multiEncodePacked()" by typecasting
 function multiStringCastPacked() public pure returns(string memory){
    string memory someString = string(multiEncodePacked());
    return someString;
 }

// \\ // \\ // \\ // \\ // \\ SECTION // \\ // \\ // \\ // \\ // \\  

// This abi.encoding stuff seems a little hard just to do string concatenation... is this for anything else?
    // Why yes, yes it is.
    // Since we know that our solidity is just going to get compiled down to this binary stuff to send a transaction...

    // We could just use this superpower to send transactions to do EXACTLY what we want them to do...

    // Remeber how before I said you always need two things to call a contract:
    // 1. ABI
    // 2. Contract Address?
    // Well... That was true, but you don't need that massive ABI file. All we need to know is how to create the binary to call
    // the functions that we want to call.

    // Solidity has some more "low-level" keywords, namely "staticcall" and "call". We've used call in the past, but
    // haven't really explained what was going on. There is also "send"... but basically forget about send.

    // call: How we call functions to change the state of the blockchain.
    // staticcall: This is how (at a low level) we do our "view" or "pure" function calls, and potentially don't change the blockchain state.

    // When you call a function, you are secretly calling "call" behind the scenes, with everything compiled down to the binary stuff
    // for you. Flashback to when we withdrew ETH from our raffle:

    function withdraw(address recentWinner) public {
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        require(success, "Transfer Failed");
    }

    // Remember this?
    // - In our {} we were able to pass specific fields of a transaction, like value.
    // - In our () we were able to pass data in order to call a specific function - but there was no function we wanted to call!
    // We only sent ETH, so we didn't need to call a function!
    // If we want to call a function, or send any data, we'd do it in these parathesis!

    // Let's look at another contract to explain this more...
}
