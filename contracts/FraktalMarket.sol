// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FraktalMarket is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using Address for address payable;

  struct Listing {
    uint256 tokenId;
    uint256 price;
    uint256 numberOfShares;
  }

  // STORAGE
  // Percent of item for sale
  mapping(uint256 => bool) itemIdsForSale; //id => forsale?
  mapping(uint256 => Listing) listings;

  uint256 public fee;

  // EVENTS
  event FeeUpdated(uint256 newFee);
  event ItemListed(uint256 tokenId, uint256 price, uint256 amountOfShares);
  event ItemPriceUpdated(uint256 tokenId, uint256 newPrice);
  // TODO itemSold //after buy function succeeeds
  // TODO sharesUnlisted
  // RescuedERC20Tokens
  event RescuedERC20Tokens(address tokenAddress, address to, uint256 amount);

  function transferTokenOwner(address _newOwner) public onlyOwner {
    transferOwnership(_newOwner);
  }

  // owner only
  function setFee(uint256 _newFee) external onlyOwner {
    require(_newFee >= 0, "FraktalMarket: negative fee not acceptable");
    fee = _newFee;
    emit FeeUpdated(_newFee);
  }

  //getter
  function getFee() external view returns (uint256) {
    return fee;
  }

  function getPrice(uint256 _tokenId, uint256 _numberOfShares)
    public
    view
    returns (uint256)
  {
    require(listings[_tokenId].tokenId != 0, "FraktalMarket: invalid token id");
    Listing memory listing = listings[_tokenId];
    return listing.price.mul(_numberOfShares);
  }

  //Token owner only an set price
  function listItem(
    uint256 _tokenId,
    uint256 _price,
    uint256 _numberOfShares
  ) external onlyOwner returns (bool) {
    Listing memory listing =
      Listing({
        tokenId: _tokenId,
        price: _price,
        numberOfShares: _numberOfShares
      });

    listings[_tokenId] = listing;
    itemIdsForSale[_tokenId] = true;
    emit ItemListed(_tokenId, _price, _numberOfShares);
    return true;
  }

  function updatePrice(uint256 _tokenId, uint256 _newPrice) external onlyOwner {
    Listing storage listing = listings[_tokenId];
    listing.price = _newPrice;
    emit ItemPriceUpdated(_tokenId, _newPrice);
  }

  function unlistItem(uint256 _tokenId) external onlyOwner {
    require(_tokenId > 0, "FraktalMarket: invalid token id");
    delete listings[_tokenId];
    itemIdsForSale[_tokenId] = false;
  }

  //TODO
  function buy(uint256 _tokenID, uint256 _numberOfShares)
    external
    payable
    nonReentrant
  {
    uint256 totalPrice = getPrice(_tokenID, _numberOfShares).add(fee);
    require(msg.value > totalPrice, "FraktalMarket: insufficient funds");

    address payable buyer = payable(msg.sender);
    Listing memory listing = listings[_tokenID];
    require(listing.tokenId != 0, "FraktalMarket: invalid token id");
    require(
      listing.numberOfShares >= _numberOfShares,
      "FraktalMarket: requestd shares amount exceeds balance"
    );
    // Couldn't proceed further due to technical gap.
  }

  // ==== optional erc20 rescue function === //
  function rescueERC20(
    address _tokenAddress,
    address _to,
    uint256 _amount
  ) public onlyOwner {
    IERC20 c = IERC20(_tokenAddress);

    c.transfer(_to, _amount);
    emit RescuedERC20Tokens(_tokenAddress, _to, _amount);
  }
}
