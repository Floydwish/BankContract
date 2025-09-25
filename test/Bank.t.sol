// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {myBank} from "../src/Bank.sol";

contract BankTest is Test {
    myBank public bank;
    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");

    function setUp() public {

        vm.prank(owner);      // 设置msg.sender为owner
        bank = new myBank();  // owner就是合约的部署者, 即 owner 为 Bank 合约的所有者
        vm.deal(user1, 3 ether);
        vm.deal(owner, 0 ether);
    }

    function test_deposit_success() public {
        bank.deposit{value: 1 ether}();
    }

    function test_deposit_failed_zero_amount() public {
        vm.expectRevert("Deposit amount must greater than 0");
        bank.deposit{value: 0 ether}();
    }

    function test_withdraw_success() public {
        // 1. 先存入 2 ether
        vm.prank(user1);
        bank.deposit{value: 2 ether}();

        // 2. 用 owner 提款 1 ether
        vm.prank(owner);
        bank.withdraw(1 ether);

        // 3. 检查 owner 余额
        console.log("owner balance", owner.balance);
        assertEq(owner.balance, 1 ether);

        // 4. 检查 user1 余额
        console.log("user1 balance", user1.balance);
        assertEq(user1.balance, 1 ether);

        // 5. 检查合约余额
        console.log("contract balance", address(bank).balance);
        assertEq(address(bank).balance, 1 ether);
    }

    function test_withdraw_failed_not_owner() public {
        vm.prank(user1);
        vm.expectRevert("You are not the owner");
        bank.withdraw(1 ether);
    }
    
    function test_withdraw_failed_insufficient_balance() public {
        vm.prank(owner);
        vm.expectRevert("Insufficient balance");
        bank.withdraw(2 ether);
    }

}