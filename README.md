# DEGEN TOKEN (ERC20)

The `DegenToken` contract is an `ERC20` token used by Degen Gaming to allow players to earn, transfer, redeem, and burn tokens within their ecosystem.

## Key Features

`Mint Tokens`: Only the owner can create new tokens.

`Transfer Tokens`: Players can transfer tokens to others.

`Redeem Tokens`: Players can exchange tokens for in-game items.

`Check Balance`: Players can view their token balance.

`Burn Tokens`: Players can destroy their own tokens.

`Add Items`: The owner can add or update in-game items available for redemption.

## Complete Codebase
```solidity
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
```

## Functions Explained

1. Constructor
    ```solidity
    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        mintTokens(msg.sender, 1000);
    
        addItem("Degen T-shirt", 100);
        addItem("Sneakers", 200);
        addItem("IPhone X", 700);
    }
    ```
    The constructor sets up the token’s name and symbol, assigns ownership, mints an initial supply of tokens to the deployer, and pre-populates the store with a few items available for redemption.

2. Minting New Tokens
   ```solidity
    function mintTokens(address to, uint256 amount) public onlyOwner {
      _mint(to, amount);
    }
   ```
   Only the contract owner can mint new tokens to reward players.

3. Transferring Tokens
   ```solidity
    function transferTokens(address to, uint256 amount) public {
        require(to != address(0), "Invalid address");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to transfer");
        _transfer(msg.sender, to, amount);
    }
   ```
   Allows players to transfer tokens to others, with checks for valid addresses and sufficient balance.

4. Redeeming Tokens
   ```solidity
    function redeemItem(string memory itemName, uint256 quantity) public {
        StoreItem memory item = storeItems[itemName];
        require(item.exists, "Item does not exist");
        uint256 cost = REDEMPTION_RATE * quantity;
        require(balanceOf(msg.sender) >= cost, "Not enough tokens");
    
        itemOwned[msg.sender][itemName] += quantity;
        _burn(msg.sender, cost);
    }
   ```
   Players can redeem tokens for in-game items. The cost is based on a fixed rate, and items are tracked in the `itemOwned` mapping.

5. Checking Token Balance
   ```solidity
    function checkTokenBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }
   ```
   Allows players to view their current token balance.

6. Burning Tokens
   ```solidity
    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to burn");
        _burn(msg.sender, amount);
    }
   ```
   Enables players to burn their tokens when they no longer need them.

7. Adding Items
   ```solidity
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
   ```
   Allows the owner to add new items or update the price of existing items available for redemption. Items are tracked in the `storeItems` mapping and listed in `itemNames`.
