pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
    uint public intialBalance = 1 ether;
    SupplyChain supply_chain = SupplyChain(DeployedAddresses.SupplyChain());

    function beforeAll() public {
        bool itemAdded = supply_chain.addItem("item 1", 1000);
        Assert.equal(itemAdded, true, "Item 1 not added");

        itemAdded = supply_chain.addItem("item 2", 1000);
        Assert.equal(itemAdded, true, "Item 2 not added");
    }


    // buyItem

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale

    function testbuyItem() public {
        bool result;
        (result, ) = address(supply_chain).call.value(500)(abi.encodePacked(supply_chain.buyItem.selector, uint(0)));
        Assert.isFalse(result, "failure, insufficient enough ether");

        supply_chain.buyItem.value(5000)(0);
        (, , , uint state, , ) = supply_chain.fetchItem(0);
        Assert.equal(state, 1, "Not sold");

        (result, ) = address(supply_chain).call.value(5000)(abi.encodePacked(supply_chain.buyItem.selector, uint(0)));
        Assert.isFalse(result, "Already sold");
    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    function testshipItem() public {
        bool result;
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.shipItem.selector, uint(0)));
        Assert.isTrue(result, "seller must be caller");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.shipItem.selector, uint(1)));
        Assert.isFalse(result, "item is marked sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

    function testreceiveItem() public {
        bool result;
        (, , , uint state, , ) = supply_chain.fetchItem(0);
        Assert.equal(state, 2, "not shipped.");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.receiveItem.selector, uint(0)));
        Assert.isTrue(result, "buyer must be caller");
        (result, ) = address(supply_chain).call(abi.encodePacked(supply_chain.receiveItem.selector, uint(1)));
        Assert.isFalse(result, "not shipped");
    }

    function() external payable {}

}
