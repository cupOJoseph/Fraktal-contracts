// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FraktalMarket {
  constructor() public {
    //set owner
  }

  // STORAGE
  // Percent of item for sale
  mapping (uint => uint) percentForSale; //id -> percent of 100
  mapping (uint => bool) someMapping; //id => forsale?

  uint fee;

  // EVENTS
  // TODO fee updates
  // TODO itemListed
  // TODO itemSold //after buy function succeeeds
  // TODO sharesUnlisted

  // owner only
  function setFee() {

  }

  //getter
  function getFee() {

  }

  //Token owner only an set price
  function listItem(tokenID, price, numberOfShares) {
    //require owner of token
  }

  //TODO
  function updatePrice(tokenID, ) {

  }

  //TODO
  function unlistItem(){

  }

  //TODO
  function buy(tokenID, numberOfShares) payable {
    //msg.value > getPrice()
  }


  // ==== optional erc20 rescue function === //
   function rescueERC20(address tokenAddress, address to, uint amount) public {
       require(msg.sender == ownerChess);
       IERC20 c = IERC20(tokenAddress);

       c.transfer(to, amount);
       emit rescuedERC20Tokens(tokenAddress, to, amount);
   }


}
