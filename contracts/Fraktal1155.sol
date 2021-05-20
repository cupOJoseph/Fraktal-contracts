// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Fraktal1155 is Ownable{

  //maps the 1155 id from the shares tokens to the NFT id.
  mapping (uint => uint) tokenIdToShares;
  mapping(uint => uint) sharesIdToToken;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint mintingFee;


  //EVENTS
  event Minted(uint nftId, uint sharedId, address shareOwner, string URI);
  event TransferedContractOwner();
  event FeeSet(uint fee);
  event LockedSharesForTransfer(address shareOwner, uint tokenId, address to, uint numShares);
  event UnlockedSharesForTransfer(address shareOwner, uint tokenId, address to, uint numShares);


  constructor() public {
    mintingFee = 0;
  }

  function mint(address _to, string memory tokenURI) public{
    //mint a new NFT, owned by this contract, with tokenURI
    _tokenIds.increment();
    _mint(address(this), _tokenIds.current(), 1, tokenURI);

    tokenIdToShares[_tokenIds.current()] = _tokenIds.current() + 1;
    sharesIdToToken[_tokenIds.current() + 1] = _tokenIds.current();

    //mint 100% of the shares for _to address
    _tokensIds.increment();
    _mint(_to, _tokenIds.current(), 10000, string(sharesIdToNFT[_tokenIds.current()])); //2 decimal places.
  }

  //TODO
  //getter shares id from tokenreverse

  /*
   * Lookup the owner of an NFT and get the percentage of their ownership.
   * returns percentage with 2 decimal places. Divide by 100 to get natural percent
   */
  function getPercentByNFT(address _owner, uint _id) external view returns(uint percent){
      //return _balances[tokenIdToShares[_id]][_owner];
      return balanceOf(_owner, tokenIdToShares[_id]);
  }

  function setFee(uint _mintingFee) public onlyOwner{
    mintingFee = _mintingFee;
    FeeSet(mintingFee);
  }

  /*
   * NFT TRANSFERS BY SHARE
   * Users can lock their shares in order to vote on transfering the entire NFT to one address
   */
   //track number of total shares an owner has locked on an NFT. owner=>tokenId=>num shares locked
   mapping (address => mapping (uint => uint)) private lockedShares;
   //Track owner address -> tokenId int -> send to address -> shares voted
   mapping (address => mapping (uint => (address => uint))) private transferVotes;
   //track total locked to a particular transfer tokenId => to address => amount of shares voting this way total;
   mapping (uint => mapping (address => uint)) lockedToTotal;

  function lockSharesTransfer(uint _tokenId, uint numShares, address _to) {
    //Owner must have this many shares, and they much be unlocked.
    require(getPercentByNFT(msg.sender, _tokenId) - lockedshares[msg.sender][_tokenId] >= numShares);

    lockedShares[msg.sender][_tokenId] += numShares;
    transferVotes[msg.sender][_tokenId][_to] += numShares;
    lockedToTotal[_tokenId][_to] += numShares;

    emit LockedSharesForTransfer(msg.sender, _tokenId, _to, numShares);
  }

  function unlockSharesTransfer(uint _tokenId, uint numShares, address _to){
    require(lockedshares[msg.sender][_tokenId][_to] >= numShares); //must have enough shares to unlock;

    lockedShares[msg.sender][_tokenId] -= numShares;
    transferVotes[msg.sender][_tokenId][_to] -= numShares;
    lockedToTotal[_tokenId][_to] -= numShares;

    emit UnlockedSharesForTransfer(msg.sender, _tokenId, _to, numShares);
  }

  function getLockedTransferShares(uint _tokenId) public view returns (uint) {
    return
  }

  function getLockedTransferShares(uint _tokenId, address _to) public view returns (uint) {

  }

  function processFullShareTransfer() {

  }

  /*
    *override default 1155 transfers
    *require shares arent locked being sent for the FT
    *require all shares are locked for the same send for the NFT
  */
  function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        override
    {
        //Fractal Requirements
        if(tokenIdToShares[id] > 0){
          //this is an NFT, require all the shares are locked
          require(
            (lockedToTotal[id][to] == 10000)
            &&  (from == _msgSender() || isApprovedForAll(from, _msgSender())),
              "ERC1155: caller has not transferLocked this many shares to this transfer."
          );
          }
        else{
          //these are shares
          //Owner must have this many shares, and they much be unlocked.
          require(
            (getPercentByNFT(msg.sender, _tokenId) - lockedshares[msg.sender][_tokenId] >= amount)
            &&  (from == _msgSender() || isApprovedForAll(from, _msgSender())),
              "Fraktal ERC1155: caller does not have this many unlocked shares."
          );
        }


        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

}
