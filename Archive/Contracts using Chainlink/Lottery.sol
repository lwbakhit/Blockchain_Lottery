pragma solidity ^0.6.0;

import "https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/ChainlinkClient.sol";
import "./Guidlines.sol";
import "./Randomness.sol";


contract Lottery is ChainlinkClient {
    
    enum lottoState {collecting, closed, calculating_winner}
    lottoState public lottery_state; 
    address payable[] public ticket_holders; 
    uint public Lottery_id;

    constructor() public {
        setPublicChainlinkToken();
        Lottery_id = 1; 
        lottery_state = lottoState(closed);
    }

    function begin_lottery(uint duration) public {
        require (lottery_state == lottoState.closed, "Lotto in progress, please wait!");
        lottery_state = lottoState.collecting;
        Chainlink.Request memory req = buildChainlinkRequest(CHAINLINK_ALARM_JOB_ID, address(this), this.fulfill_alarm.selector);
        req.addUint("Until", now + duration);
        sendChainlinkRequestTo(CHAINLINK_ALARM_ORACLE, req, ORACLE_PAYMENT);
    }

  function fulfill_alarm(bytes32 _requestId) public recordChainlinkFulfillment(_requestId) {
        require(lottery_state == lottoState.collecting, "The time to buy is now!");
        lottery_state = lottoState.calculating_winner;
        lotteryId = Lottery_id + 1;
        pickWinner();
    }
    
    function enter() public payable {
        assert(msg.value == buyIn);
        assert(lottery_state == lottoState.collecting);
        buyers.push(msg.sender);
    } 
    
    function selectWinner() private {
        require(lottery_state == lottoState.calculating_winner, "Winner selection in progress");
        RandomnessInterface(governance.randomness()).getRandom(lotteryId, lotteryId);
        //this kicks off the request and returns through fulfill_random
    }
    
    
    
    

}