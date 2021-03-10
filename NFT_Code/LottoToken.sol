pragma solidity 0.5.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";

contract LotteryToken is ERC721Full, Ownable {
    
    struct LottoTokenStructure {
        uint256 amount;
        address purchaser;
    }
    

    // a progressive id
    uint256 private _progressiveId;

    // max available number of lottotokens
    uint256 private _maxSupply;

    // Mapping from token ID to the structures
    mapping(uint256 => LottoTokenStructure) private _structureIndex;
    
    // checks if we can generate tokens
    modifier canGenerate() {
        require(_progressiveId < _maxSupply,"Max token supply reached");
        _;
        
    }
    constructor() public ERC721Full("DefiLotto", "DFT") {
        
    }
        
    function progressiveId() external view returns (uint256) {
        return _progressiveId;
    }
    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }
    
    function newLottoToken(uint256 amount, address purchaser, address beneficiary) public returns (uint256) {
        uint256 tokenId = _progressiveId.add(1);
        _mint(beneficiary, tokenId);
        _structureIndex[tokenId] = LottoTokenStructure(amount,purchaser);
        _progressiveId = tokenId;
        return tokenId;
    }
    
    function isVisible (uint256 tokenId) external view returns (bool visible, uint256 date) {
        if (_exists(tokenId)) {
            LottoTokenStructure storage LottoToken = _structureIndex[tokenId];
            visible = block.timestamp >= LottoToken.date;
            date = LottoToken.date;
            
        } 
        else {
            visible = false;
            date = 0;
        }
    
    }
    
    function getLottoToken (uint256 tokenId) external view returns (uint256 amount, address purchaser, address beneficiary, uint256 date) {
        require(_exists(tokenId),"Token must exists");
        LottoTokenStructure storage LottoToken = _structureIndex[tokenId];

        require(block.timestamp >= LottoToken.date, "Now should be greater than gift date");
        amount = LottoToken.amount;
        purchaser = LottoToken.purchaser;
        beneficiary = ownerOf(tokenId);
        date = LottoToken.date;
    }
    
    function burn(uint256 tokenId) external {
        address tokenOwner = isOwner() ? ownerOf(tokenId) : msg.sender;
        super._burn(tokenOwner, tokenId);
        delete _structureIndex[tokenId];
    }

}