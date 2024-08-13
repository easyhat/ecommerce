// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 0x16ed59DD6350fC6Ea1084A8D80788a242997D343
contract EcommerceEscrow {
    address public owner;
    struct Product {
        uint id;
        string name;
        string description;
        uint price; // Price in Wei
        address payable seller;
        address payable buyer;
        bool purchased;
        bool delivered;
    }

    uint public productCounter = 0;
    mapping(uint => Product) products;

    constructor() {
        owner = msg.sender;
    }

    // events
    event ProductAdded(uint id, string name, uint price, address seller);
    event ProductPurchased(uint id, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier productExists(uint _id) {
        require(products[_id].id == _id, "Product does not exist");
        _;
    }

    modifier notPurchased(uint _id) {
        require(!products[_id].purchased, "Product already purchased");
        _;
    }

    function addProduct(
        string memory _name,
        string memory _description,
        uint _price
    ) public onlyOwner {
        require(_price > 0, "Price must be greater than zero");
        productCounter++;
        products[productCounter] = Product(
            productCounter,
            _name,
            _description,
            _price,
            payable(msg.sender), // Seller's address
            payable(address(0)), // Initially, no buyer
            false, // Not purchased
            false // Not delivered
        );
        emit ProductAdded(productCounter, _name, _price, msg.sender);
    }

    function purchaseProduct(
        uint _id
    ) public payable productExists(_id) notPurchased(_id) {
        Product storage _product = products[_id];
        require(msg.value >= _product.price, "Insufficient funds");

        // Record the buyer's address
        _product.buyer = payable(msg.sender);
        _product.purchased = true;

        // Emit the purchase event
        emit ProductPurchased(_id, msg.sender);
    }

    function confirmDelivery(uint _id) public productExists(_id) {
        Product storage _product = products[_id];
        require(
            msg.sender == _product.buyer,
            "Only the buyer can confirm delivery"
        );
        require(_product.purchased, "Product must be purchased");
        require(!_product.delivered, "Delivery already confirmed");

        // Transfer funds to the seller
        _product.seller.transfer(_product.price);

        // Mark the product as delivered
        _product.delivered = true;
    }

    function raiseDispute(uint _id) public view productExists(_id) {
        Product storage _product = products[_id];
        require(
            msg.sender == _product.buyer || msg.sender == _product.seller,
            "Only buyer or seller can raise a dispute"
        );
        require(_product.purchased, "Product must be purchased");
        require(!_product.delivered, "Cannot dispute after delivery");
    }

    function requestRefund(uint _id) public productExists(_id) {
        Product storage _product = products[_id];
        require(
            msg.sender == _product.buyer,
            "Only the buyer can request a refund"
        );
        require(!_product.delivered, "Cannot refund after delivery");

        // Refund the buyer
        _product.buyer.transfer(_product.price);

        // Mark the product as refunded (optional)
        _product.purchased = false;
    }

    function getProduct(
        uint _id
    ) public view returns (string memory, string memory, uint, address, bool) {
        Product memory _product = products[_id];
        return (
            _product.name,
            _product.description,
            _product.price,
            _product.seller,
            _product.purchased
        );
    }
}
