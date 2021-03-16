pragma solidity ^0.5.5;

import "./LottoTokenMarket.sol";
import "./LottoTokenNFT.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";

contract winningToken is Ownable {
    
    enum LOTTERY_STATE {OPEN, CLOSED, SELECTING_WINNER}
    LOTTERY_STATE public lottery_state;
    uint duration;
    uint[] public lottery_tokens_purchased;
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    
    mapping(uint256 => address payable) public tokendict;
    
    
    // The token being sold
    LotteryToken private _token;
    
    // Address where funds are collected --> can we set this to a contact that will collect the funds and then send them to the winner? 
    address payable addr = address(uint160(address(this)));
    
    address payable purchaser;
    
    address payable lotto_runner;
    
    address payable winner;
    
    // The price for a token --- > can we set this to a fixed price even though they will be NFTs? And if you pay more than the price of one you recieve multiple tokens
    uint256 private _price;
    
    uint fakenow = now;
    
    event TokenPurchase(address indexed purchaser, address indexed addr, uint256 value, uint256 tokenId);

    
    constructor(uint256 price, address payable lotto_runner, address token) public {
        require(token != address(0),"Token can't be the zero address");

        _price = price;

        _token = LotteryToken(token);
    }
    
    function start_new_lottery() public {
        require(lottery_state == LOTTERY_STATE.CLOSED,"Can't start a new lottery while one is under way");
        lottery_state = LOTTERY_STATE.OPEN;
        duration = fakenow + 24 hours;
    }
    function fastforward() public {
        fakenow + 30 hours;
        lottery_state = LOTTERY_STATE.SELECTING_WINNER;
    }
    
    function pickWinner() external view returns (uint256) {
        require(lottery_state == LOTTERY_STATE.SELECTING_WINNER, "Lottery still in process");
        require(lottery_tokens_purchased.length > 0);
        uint winningToken = generateRandom() % lottery_tokens_purchased.length;
        address payable winner = tokendict[winningToken];
        return winningToken;
    }
    
    function distributeWinnings() public payable {
        require(lottery_state == LOTTERY_STATE.SELECTING_WINNER, "Lottery has not been completed");
        uint points = address(this).balance.div(100);
        uint total;
        uint amount;
        
        // Distribute to winner
        if address = winningToken {
        amount = points.mul(90);
        total = total.add(amount);
        winner.transfer(amount);
        }
        
        else address = lotto_runner {
        // Distribute to owner
        amount = points.mul(10);
        total = total.add(amount);
        lotto_runner.transfer(amount);
        }
        
    }
    
    function generateRandom() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, lottery_tokens_purchased)));
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
}