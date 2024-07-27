pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { Market } from "../src/Market.sol";
import { USDCtoken } from "../src/USDC.sol";
import { MyToken } from "../src/myToken.sol";
import { Vault } from "../src/Vault.sol";
import { Check } from "../src/Check.sol";

contract MarketTest is Test {
    Market public market;
    USDCtoken public usdcToken;
    MyToken public myToken;
    Vault public vault;
    Check public check;
    address owner = vm.addr(1);
    address customer = vm.addr(2);

    // 1 addr - owner of everything
    // 2 addr - customer

    function setUp() public {
        vault = new Vault();
        market = new Market(owner, address(vault));
        check = new Check(owner);

        usdcToken = new USDCtoken(owner);
        myToken = new MyToken(owner);

        vm.deal(customer, 10 ether);
    }

    modifier base(){
        vm.startPrank(owner);

        // дали по 100 токенов каждого типа customer
        usdcToken.mint(customer, 100);
        myToken.mint(customer, 100);
        // устаналиваем MTK
        market.setUpMyToken(address(myToken));
        market.allowToken(address(usdcToken));
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

    function testBalanceMoreThen0CustomerAndMarket() public base{
        assertEq(usdcToken.balanceOf(customer), 100);
        assertEq(myToken.balanceOf(customer), 100);
        assertEq(usdcToken.balanceOf(address(market)), 100);
        assertEq(myToken.balanceOf(address(market)), 100);
    }

    function testBuy50Tokens() public base{
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

    function testCrashifTokenIsntAllowed() public base{
        vm.prank(owner);
        market.blockToken(address(usdcToken));
        vm.startPrank(customer);
        usdcToken.approve(address(market), usdcToken.balanceOf(customer));
        vm.expectRevert("Token is not allowed");        
        market.buyToken(50, address(usdcToken));
        vm.stopPrank();
    }

    function testBuy1tokenWith2eth() public base{
        vm.startPrank(customer);
        uint startBalance = customer.balance;       
        market.buyToken{value: 2.24 ether}();
        vm.stopPrank();
        console.log(customer.balance);
        console.log(market.refund());
        assert(startBalance - customer.balance == 2.24 ether - 0.016 ether);
        assertEq(myToken.balanceOf(customer), 101);
    }
}