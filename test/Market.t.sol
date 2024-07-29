pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Market} from "../src/Market.sol";
import {USDCtoken} from "../src/TestTokens/USDC.sol";
import {MyToken} from "../src/myToken.sol";
import {Vault} from "../src/Vault.sol";
import {Check} from "../src/Check.sol";

contract MarketTest is Test {
    Market public market;
    USDCtoken public usdcToken;
    MyToken public myToken;
    Vault public vault;
    Check public check;
    address owner = vm.addr(1);
    address customer = vm.addr(2);

    function setUp() public {
        vm.startPrank(owner);

        // 1 step - vault
        vault = new Vault(owner);

        // 2 step - check
        check = new Check(address(vault));
        vault.setUpCheck(address(check));

        // 3 step - myToken
        myToken = new MyToken(owner);

        // skip step
        usdcToken = new USDCtoken(owner);

        // 4 step - market
        market = new Market(owner, address(vault), address(myToken));
        vault.setUpMarket(address(market));

        vm.deal(customer, 10 ether);
    }

    modifier base() {
        vm.startPrank(owner);

        // дали по 100 токенов каждого типа customer
        usdcToken.mint(customer, 100);
        myToken.mint(customer, 100);
        market.allowToken(address(usdcToken), true);

        // дали по 100 токенов каждого типа market
        usdcToken.mint(address(market), 100);
        myToken.mint(address(market), 100);

        vm.stopPrank();
        _;
    }

    function testMarketAddressIsntZero() public {
        assertTrue(address(market) != address(0), "adress should be not zero");
    }

    function testBalanceOfCustomerIsntZero() public {
        // console.log(address(customer).balance);
        assert(address(customer).balance > 0);
    }

    function testAllContractsCanBeDeployed() public {
        assertTrue(address(market) != address(0), "adress should be not zero");
        assertTrue(address(usdcToken) != address(0), "adress should be not zero");
        assertTrue(address(myToken) != address(0), "adress should be not zero");
    }

    function testBalanceMoreThen0CustomerAndMarket() public base {
        assertEq(usdcToken.balanceOf(customer), 100);
        assertEq(myToken.balanceOf(customer), 100);
        assertEq(usdcToken.balanceOf(address(market)), 100);
        assertEq(myToken.balanceOf(address(market)), 100);
    }

    function testBuy50Tokens() public base {
        vm.startPrank(customer);
        usdcToken.approve(address(market), usdcToken.balanceOf(customer));
        market.buyToken(50, address(usdcToken));
        vm.stopPrank();

        assertEq(usdcToken.balanceOf(address(customer)), 45);
        assertEq(myToken.balanceOf(address(customer)), 150);
        assertEq(usdcToken.balanceOf(address(market)), 150);
        assertEq(myToken.balanceOf(address(market)), 50);
        assertEq(usdcToken.balanceOf(address(vault)), 5);
    }

    function testCrashifTokenIsntAllowed() public base {
        vm.prank(owner);
        market.allowToken(address(usdcToken), false);
        vm.startPrank(customer);
        usdcToken.approve(address(market), usdcToken.balanceOf(customer));
        vm.expectRevert("Token is not allowed");
        market.buyToken(50, address(usdcToken));
        vm.stopPrank();
    }

    function testBuy1tokenWith2eth() public base {
        vm.startPrank(customer);
        uint256 startBalance = customer.balance;
        market.buyToken{value: 2.24 ether}(0, address(0));
        vm.stopPrank();
        console.log(customer.balance);
        assert(startBalance - customer.balance == 2.24 ether - 0.016 ether);
        assertEq(myToken.balanceOf(customer), 101);
    }

    function testDeposit() public base {
        vm.startPrank(customer);
        usdcToken.approve(address(vault), usdcToken.balanceOf(customer));
        vault.makeDeposit(50, address(usdcToken));
        vm.stopPrank();

        assertEq(usdcToken.balanceOf(address(vault)), 50);
        assertEq(check.balanceOf(customer), 1);
    }

    function testReturnDepositTokens() public base {
        vm.prank(owner);
        usdcToken.mint(address(vault), 100);

        // делаем депозит
        vm.startPrank(customer);
        usdcToken.approve(address(vault), usdcToken.balanceOf(customer));
        vault.makeDeposit(100, address(usdcToken));

        // возвращаем депозит
        check.approve(address(vault), 0);
        vault.returnDeposit(0);
        vm.stopPrank();

        assertEq(usdcToken.balanceOf(address(vault)), 98);
        assertEq(usdcToken.balanceOf(customer), 102);
        assertEq(check.balanceOf(customer), 0);
    }

    function testReturnDepositEth() public base {
        vm.deal(address(vault), 1 ether);
        vm.startPrank(customer);
        vault.makeDeposit{value: 2 ether}(0, address(0));

        assertEq(check.balanceOf(customer), 1);
        assertEq(address(vault).balance, 3 ether);

        check.approve(address(vault), 0);
        vault.returnDeposit(0);
        assertEq(check.balanceOf(customer), 0);
        assertEq(address(vault).balance, 0.96 ether);
        assertEq(customer.balance, 10.04 ether);

        vm.stopPrank();
    }
}
