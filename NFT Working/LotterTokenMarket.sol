pragma solidity ^0.5.5;

import "./LotteryTokenNFT.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";



contract LotteryTokenMarketPlace is Ownable {
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    
    mapping(uint256 => address payable) public tokendict;
    
    
    // The token being sold
    LotteryToken private _token;
    
    // Address where funds are collected --> can we set this to a contact that will collect the funds and then send them to the winner? 
    address payable addr = address(uint160(address(this)));
    
    
    address payable purchaser;
    
    
    // The price for a token --- > can we set this to a fixed price even though they will be NFTs? And if you pay more than the price of one you recieve multiple tokens
    uint256 private _price;
    
   
    event TokenPurchase(address indexed purchaser, address indexed addr, uint256 value, uint256 tokenId);

    
    constructor(uint256 price, address token) public {
        require(token != address(0),"Token can't be the zero address");

        _price = price;

        _token = LotteryToken(token);
    }

    // The beneficiary should be the contract referenced above and the purchaser should not necessarily be the msg.sender? ? ?
    function buyToken(address payable purchaser) external payable {
        require(msg.value >= _price,"Not enough funds");
        uint256 weiAmount = msg.value;
        _preValidatePurchase(weiAmount);
    
        uint256 tokenValue = msg.value.sub(_price);

        uint256 lastTokenId = _processPurchase(tokenValue,purchaser);

        emit TokenPurchase(purchaser, addr,tokenValue,lastTokenId);

    }
    
    
    function token() external view returns (LotteryToken) {
        return _token;
     }

    //function wallet() external view returns (address) {
    //    return _wallet;
    //}

    function price() external view returns (uint256) {
        return _price;
    }
    
    function setPrice(uint256 newPrice) external onlyOwner {
        _price = newPrice;
    }
    
    //function setWallet(address payable newWallet) external onlyOwner {
      //  require(newWallet != address(0),"Wallet can't be the zero address");
        
     //   _wallet = newWallet;
    //}
    
    function _preValidatePurchase(uint256 weiAmount) internal view {
        require(addr != address(0),"Beneficiary can't be the zero address");
        require(weiAmount >= _price,"Sent ETH must be greater than or equal to token price");
    }
    
    function _processPurchase(uint256 amount, address payable _purchaser) internal returns (uint256) {
        return _token.newLottoToken(amount,_purchaser);
    }
    
    function balance() public view returns(uint) {
        return address(this).balance;
    }
    
}