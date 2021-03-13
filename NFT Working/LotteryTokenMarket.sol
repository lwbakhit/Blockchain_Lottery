pragma solidity ^0.5.5;

import "./LotteryTokenNFT.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";



contract LotteryTokenMarketPlace is Ownable {
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    // List of participants and their address
    address payable[] public lotteryBag;
    uint[] public lotterytokens;
    // Address of the lottery runner (i.e. the house)
    address payable The_House;
    // Structure containing the participants information
    struct Participants {
        string name;
        address purchaser;
    }
    
    // Mapping Token id to structure above
    mapping(uint256 => Participants) public participant_information;
    // Mapping of token id to the address of the purchaser
    mapping(uint256 => address payable) public tokendict;
    // The token being sold
    LotteryToken private _token;
    // Address where funds are collected --> in this case the contract
    address payable addr = address(uint160(address(this)));
    // Address of purchaser
    //address payable purchaser;
    // Setting the lottery state as live through a boolean
    bool public isLotteryLive;
    // The price for a token
    uint256 private _price;
    // Pot 
    uint pot = address(this).balance;
    // Event for when the token is purchased. This will be emitted during the purchase of tokens. Please see the function below. 
    event TokenPurchase(address indexed purchaser, address indexed addr, uint256 value, uint256 tokenId);
    // Constructor
    constructor(uint256 price, address token) public {
        require(token != address(0),"Token can't be the zero address");
        
        The_House = msg.sender;

        _price = price;

        _token = LotteryToken(token);
    }
    // Function for activating the lottery. This will serve as a added level of protection in the lottery.
    function activateLottery() public {
        require(msg.sender == The_House, "You are not authorized to start the lottery!");
        isLotteryLive = true;
    }
    // Function for deactivating the lottery
    function deactiveLottery() public {
        require(msg.sender == The_House, "You are not authorized to end the lottery!");
        isLotteryLive = false;
    }
    // Function for buying tokens, which will serve as the lottery tickets. The lottery must be live.
    function buyToken(string calldata name, address payable purchaser) external payable {
        require(isLotteryLive == true, "Lottery is not currently running");
        require(msg.value >= _price,"Not enough funds");
        uint256 ETHAmount = msg.value;
        _preValidatePurchase(ETHAmount);
    
        uint256 tokenValue = msg.value.sub(_price);

        uint256 lastTokenId = _processPurchase(tokenValue,purchaser);

        emit TokenPurchase(purchaser, addr,tokenValue,lastTokenId);
        // Pushing the purchaser to the list of participants.
        lotteryBag.push(purchaser);
        lotterytokens.push(lastTokenId);
        tokendict[lastTokenId] = purchaser;
        participant_information[lastTokenId] = Participants(name, purchaser);

    }
    // Function for declaring the winner. Lottery cannot be live.
    function declare_winner() public {
        require(msg.sender == The_House, "You are not authorized to declare a winner!");
        require(lotteryBag.length > 1, "Not enough participants to select a winner! Please reopen lottery.");
        require(isLotteryLive == false, "Lottery is still in progress!");
        uint index = generateRandomNumber() % lotterytokens.length;
        //lotteryBag[index].transfer(address(this).balance);
        tokendict[index].transfer(address(this).balance);
    }
    
    
    // Return the token name.
    function token() external view returns (LotteryToken) {
        return _token;
     }
    // Return the ticket price
    function price() external view returns (uint256) {
        return _price;
    }
    // Set new ticket price.
    function setPrice(uint256 newPrice) external onlyOwner {
        _price = newPrice;
    }
    // Generate a random number. This will use the list of participants and select randomly an index. Based on this index, a winning address will be declared.
    function generateRandomNumber() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, lotterytokens)));
    }
    
    function _preValidatePurchase(uint256 weiAmount) internal view {
        require(addr != address(0),"Beneficiary can't be the zero address");
        require(weiAmount >= _price,"Sent ETH must be greater than or equal to token price");
    }
  
    function _processPurchase(uint256 amount, address payable _purchaser) internal returns (uint256) {
        return _token.newLottoToken(amount,_purchaser);
    }
    // Get the balance of the current pot
    function get_pot_balance() public view returns(uint) {
        return address(this).balance;
    }

}