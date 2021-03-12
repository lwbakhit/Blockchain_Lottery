pragma solidity ^0.5.5;

import "./LotteryTokenNFT.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";



contract LotteryTokenMarketPlace is Ownable {
    
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
    
    // The beneficiary should be the contract referenced above and the purchaser should not necessarily be the msg.sender? ? ?
    function buyToken(address payable purchaser) external payable {
        require(msg.value >= _price,"Not enough funds");
        require(purchaser.balance >= _price, "Not enough funds in wallet");
        require(lottery_state == LOTTERY_STATE.OPEN,"Lottery is currently closed");
        require(duration > fakenow, "Lottery time has expired");
        uint256 weiAmount = msg.value;
        _preValidatePurchase(weiAmount);
    
        uint256 tokenValue = msg.value.sub(_price);

        uint256 lastTokenId = _processPurchase(tokenValue,purchaser);

        emit TokenPurchase(purchaser, addr,tokenValue,lastTokenId);
        tokendict[lastTokenId] = purchaser;
        lottery_tokens_purchased.push(lastTokenId);

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
        amount = points.mul(90);
        total = total.add(amount);
        winner.transfer(amount);
        
        // Distribute to owner
        amount = points.mul(10);
        total = total.add(amount);
        lotto_runner.transfer(amount);

        
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
    
    function _processPurchase(uint256 amount, address payable _purchaser) internal returns (uint256) {
        return _token.newLottoToken(amount,_purchaser,addr);
    }
    
    function balance() public view returns(uint) {
        return address(this).balance;
    }
    
}
    
    
    