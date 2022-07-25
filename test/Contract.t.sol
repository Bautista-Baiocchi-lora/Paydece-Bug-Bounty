// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract ContractTest is Test {

    struct FuzzyCreateEscrow {
        uint _orderId; 
        address payable _buyer; 
        address payable _seller; 
        uint _value; 
        uint _sellerfee; 
        uint _buyerfee;
    }


    function setUp() public {}

    function testCreateEscrow(FuzzyCreateEscrow inputs) public {
        assertTrue(true);
    }
}
