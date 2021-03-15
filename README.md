# Blockchain_Lottery

## Deployment Demonstration & Instructions

After the code has been written, we can proceed with the deployment and running of the lottery. 

1) First, we will compile and deploy the LotteryToken.sol solidity file. This will set up our actual token using the ERC721 standard. When the MetaMask notification pops up, please hit 'Confirm' to continue. 

![LotteryTokenDeploy](./Images/lottery_token_deploy.png)


2) Next, we can deploy the LotteryTokenMarket.sol solidity file. This file and contract will allow wallet address to enter our contract unsolicited and purchase our NFT tokens in order to be apart of the lottery. 

To deploy, you will have to provide a price for the NFTs and a token address. For a token address, please copy the address from the previously deployed LotteryToken contract. Again, when the MetaMask notification appears, select 'Confirm' to continue.

![LotteryTokenMarketDeploy](./Images/lottery_token_market_deploy.png)

3) Once we have deployed both contracts, we will want to activate the lottery through the LotteryTokenMarket contract. In our code, we have create a boolean to declare whether or not the lottery is active. In order for participants to purchase tokens, we will need to activate the lottery.

![ActivateLottery](./Images/activate_lottery.png)

4) Once the lottery has been activate, participants will be allowed to begin purchasing their tokens. When they purchase, they will have to enter their wallet address and their names. These attributes will be added to *struct* and *mapping* objects so that we can keep track of the participant's information and declare a winner at the end. 

In this demonstration, I will be using two address from my Ganache and will name them 'Bill' and 'Carl'. In order to purchase, you will need to insert 1 in the value field above the deployed contracts

![Value](Images/value.png)

![Bill_Purchase](Images/bill_purchase.png)

![Carl_Purchase](Images/carl_purchase.png)

5) After our participants have purchased their tokens, which will serve as their lottery tickets, there are some things we can do to verify that our contract is working correctly. First, we can select **get_pot_balance** in the LotteryTokenMarket contract to ensure that the balance of the contract has gone up in relation to the purchases of tokens (should be 2). Secondly, select **participant_information** and feed in either 1 or 2 to make sure that we are properly keeping track of the participants and their address. Third, we can do the same with the **tokendict** object, as we will be using this mapping to award the balance to the winner. 

![Pot_Balance](Images/pot_balance.png)

![ParticipantInformation](Images/participant_information.png)

![TokenDict](Images/token_dict.png)

We can do a similar exercise in the LotteryToken contract. By call the **totalSupply** option, we can verify that the supply has increased from 0 to 2. We can also feed in our tokenIds (1, 2, 3, 4...) to the **owner** field to return the address that owns that particular token. 

![TotallySupply](Images/total_supply.png)

![Owner](Images/owner.png)

6) After we have verified that we believe the contracts are working properly in relation to our transactions, we can deactivate our lottery. This will close our lottery, forbid any further purchases, and allow us to proceed with selecting a winner. The deactivate functionality is located in the LotteryTokenMarket contract.

![DeactivateLottery](Images/deactivate_lottery.png)

7) With the lottery shutdown, we can select a winner. We can do so by selecting the **declare_winner** button in the LotteryTokenMarket contract. In the code, this will select a random, using the number of index in the lotteryTokens list. Each index corresponds to a token, and since the tokenIds and indexes increase incrementally by one, the first index will correspond to tokenId 1 and the second index will correspond to tokenId 2. 

The declare_winner function will also distribute the funds to the winner by using the winning index (i.e. tokenId) and feeding into the tokendict mapping to select the winning address.

![DeclareWinner](Images/declare_winner.png)

8) Once we have declared a winner, we will want to verify that it has properly selected a winner and distributed the funds. To begin, we can check that one of our Ganache address went up by 2 ETH. In this case, each address was 100, so it should be easy to verify.

![GanacheCheck](Images/ganache_check.png)

We can also call **get_pot_balance** again to verify that the contract balance was reduced to 0. Additionally, we can call **getWinner** to get the name of the participant who won. In this case, the winner was Bill and his Ganache address reflects a proper distribution of the winnings.

![SolidityCheck](Images/solidity_check.png)













