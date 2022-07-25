// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@test/E20.sol";
import "@src/PaydeceContract.sol";

contract ContractTester is Test {

    struct FuzzyCreateEscrow {
        uint _orderId; 
        address payable _buyer; 
        address payable _seller; 
        uint _value; 
        uint _sellerfee; 
        uint _buyerfee;
    }

    address public deployer;
    E20 public token;
    CriptoCarsEscrow public escrow;
    uint256 constant LARGE_UINT = 2**256 - 1;
    uint256 constant FAUCET_AMOUNT = 1000000000000000000000000;

    function setUp() public {
        deployer = vm.addr(10000);
        vm.label(deployer, "Deployer");
        
        vm.startPrank(deployer, deployer);
        token = new E20(18, "TestUSDT", "tUSDT");
        escrow = new CriptoCarsEscrow(token);
        vm.stopPrank();
    }

    function createEscrow(address caller, uint _orderId, address payable _buyer, address payable _seller, uint _value, uint _sellerfee, uint _buyerfee) public {
        vm.startPrank(_buyer);
        token.faucet(FAUCET_AMOUNT);
        token.approve(address(escrow), LARGE_UINT);
        vm.stopPrank();

        vm.prank(caller, caller);
        escrow.createEscrow(_orderId, _buyer, _seller, _value, _sellerfee, _buyerfee);
    }

    function testFailsToCreateEscrowWithZeroAddress(FuzzyCreateEscrow memory inputs) public {
        vm.assume(inputs._buyer == address(0));
        vm.assume(inputs._seller == address(0));

        address caller = vm.addr(10);
        vm.label(caller, "Caller");

        this.createEscrow(caller, inputs._orderId, inputs._buyer, inputs._seller, inputs._value, inputs._sellerfee, inputs._buyerfee);
    }

    function testCreateEscrow(
        uint _value,
        uint _sellerfee, 
        uint _buyerfee,
        uint _orderId
    ) public {
        vm.assume(_value < FAUCET_AMOUNT);

        address caller = vm.addr(10);
        vm.label(caller, "Caller");

        address buyer = vm.addr(20);
        vm.label(buyer, "Buyer");

        address seller = vm.addr(30);
        vm.label(seller, "Seller");

        this.createEscrow(caller, _orderId, payable(buyer), payable(seller), _value, _sellerfee, _buyerfee);
    }

    function testFailsToCreateSameEscrowTwice(
        uint _value,
        uint _sellerfee, 
        uint _buyerfee
    ) public {
        vm.assume(_value < FAUCET_AMOUNT);

        address caller = vm.addr(10);
        vm.label(caller, "Caller");

        address buyer = vm.addr(20);
        vm.label(buyer, "Buyer");

        address seller = vm.addr(30);
        vm.label(seller, "Seller");

        this.createEscrow(caller, 0, payable(buyer), payable(seller), _value, _sellerfee, _buyerfee);
        this.createEscrow(caller, 0, payable(buyer), payable(seller), _value, _sellerfee, _buyerfee);
    }

    function testFailsToReleaseEscrowFailsWithArithmeticErrorWithSellerFeeOfZero(
        uint _value,
        uint _orderId,
        uint _sellerfee
    ) public {
        vm.assume(_value > 0);
        vm.assume(_value < FAUCET_AMOUNT);

        address caller = vm.addr(10);
        vm.label(caller, "Caller");

        address buyer = vm.addr(20);
        vm.label(buyer, "Buyer");

        address seller = vm.addr(30);
        vm.label(seller, "Seller");

        this.createEscrow(caller, _orderId, payable(buyer), payable(seller), _value, _sellerfee, 0);

        vm.prank(buyer);
        escrow.releaseEscrow(_orderId);
    }
}
