// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    uint256 REDEMPTION_RATE = 100;

    struct StoreItem {
        uint256 price;
        bool exists;
    }

    struct StoreItemDetail {
        string name;
        uint256 price;
    }

    mapping(address => mapping(string => uint256)) internal itemOwned;
    mapping(string => StoreItem) internal storeItems;
    string[] internal itemNames;

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        mintTokens(msg.sender, 1000);

        addItem("Degen T-shirt", 100);
        addItem("Sneakers", 200);
        addItem("IPhone X", 700);
    }

    function mintTokens(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to burn");
        _burn(msg.sender, amount);
    }

    function transferTokens(address to, uint256 amount) public {
        require(to != address(0), "Invalid address");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to transfer");
        _transfer(msg.sender, to, amount);
    }

    function addItem(string memory itemName, uint256 price) public onlyOwner {
        if (!storeItems[itemName].exists) {
            storeItems[itemName] = StoreItem({
                price: price,
                exists: true
            });
            itemNames.push(itemName);
        } else {
            storeItems[itemName].price = price;
        }
    }

    function redeemItem(string memory itemName, uint256 quantity) public {
        StoreItem memory item = storeItems[itemName];
        require(item.exists, "Item does not exist");
        uint256 cost = REDEMPTION_RATE * quantity; // Total cost based on fixed redemption rate
        require(balanceOf(msg.sender) >= cost, "Not enough tokens");

        itemOwned[msg.sender][itemName] += quantity;
        _burn(msg.sender, cost);
    }

    function checkItemOwned(address user, string memory itemName) public view returns (uint256) {
        return itemOwned[user][itemName];
    }

    function checkTokenBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function getAllStoreItems() public view returns (StoreItemDetail[] memory) {
        StoreItemDetail[] memory items = new StoreItemDetail[](itemNames.length);
        for (uint i = 0; i < itemNames.length; i++) {
            string memory itemName = itemNames[i];
            items[i] = StoreItemDetail({
                name: itemName,
                price: storeItems[itemName].price
            });
        }
        return items;
    }
}
