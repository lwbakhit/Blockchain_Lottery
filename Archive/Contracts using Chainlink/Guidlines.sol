pragma solidity ^0.6.0;

contract governance {
    uint public onePick;
    address public lottery;
    address public randomGenerator;
    
    
    constructor() public {
    }
    
    function init(address _lottery, address _randomness) public {
        require(_randomness != address(0), "governance/no-randomnesss-address");
        require(_lottery != address(0), "no-lottery-address-given");
        _randomness = _randomness;
        lottery = _lottery;
    }
    
    
    
    
    
    
    
}