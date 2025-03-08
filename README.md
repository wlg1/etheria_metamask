To run:

1. In cmd prompt, cd to project folder and run 'npm run dev'. This launches the browser.
2. Log in to Metamask account where the contract was deployed and set the test env to Ropsten. Click 'connect' if prompted.

Now if you do not want to use an existing deployed contract:
3. Go to the remix IDE:
https://remix.ethereum.org/#optimize=false&version=soljson-v0.4.24+commit.e67f0147.js

4. In the run tab of remix, set the env to Injected Web3
5. Create first_contract.sol using the code of first_contract.sol located in the project folder.
6. Deploy first_contract.sol (onto any Metamask account). 
7. Copy its address into all the parts of each HTML file that has:
 var first_contract = ContractVar.at('0x0d7d1a126bd4b99ac2127980f1325080e5efbb2a');
 (replaced what's inside '' with the new address)
8. Now you can use Etheria on a new address