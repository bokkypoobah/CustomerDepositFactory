# Customer Deposit Factory

The CustomerDepositFactory smart contract allows Incent Loyalty to create a series of uniquely addressed deposit contracts on the Ethereum blockchain. Each of these deposit contracts can be provided to customers and when customers send ethers to their deposit contract, their ethers will be split via the factory contract in a 0.5%/0.5%/99% ratio into 3 Ethereum addresses.

<br />

<hr />

**Table of contents**

* [Deposit Contract Creation And Gas Usage](#deposit-contract-creation-and-gas-usage)
* [JSON RPC Interaction With This Contract](#json-rpc-interaction-with-this-contract)
  * [Creating New Deposit Contract Addresses](#creating-new-deposit-contract-addresses)
  * [Set The Funding Closed Flag](#set-the-funding-closed-flag)
  * [To Filter For The DepositContractCreated Topic](#to-filter-for-the-depositcontractcreated-topic)
  * [To Filter For The DepositReceived Topic](#to-filter-for-the-depositreceived-topic)
  * [To Filter For The FundingClosed Topic](#to-filter-for-the-fundingclosed-topic)
* [Testing And Results](#testing-and-results)
* [Security Audit](#security-audit)
* [Deployment Checks](#deployment-checks)


<br />

<hr />

## Deposit Contract Creation And Gas Usage

From the testing of the deposit contracts, the following gas is required for the different number of deposit contracts being created when calling the `createDepositContracts(uint256 number)` function:

Number of deposit contracts created | Gas usage
--- | ---
1 | 123
10 | 123
20 | 123

<br />

<hr />

## JSON RPC Interaction With This Contract

### Creating New Deposit Contract Addresses

The `createDepositContracts(uint256 number)` function signature follows:

    > web3.sha3('createDepositContracts(uint256)').substring(0, 10)
    "0x15891148"

Append the 0 padded number of deposit contracts to be created, for example to create 20 deposit contracts:

    0x158911480000000000000000000000000000000000000000000000000000000000000014

<br />

### Set The Funding Closed Flag

The `setFundingClosed(bool _fundingClosed)` function signature follows:

    > web3.sha3('setFundingClosed(bool)').substring(0, 10)
    "0x84f08c6b"

Append the 0 padded boolean flag 0 (off) or 1 (on), for example to close off the funding:

    0x84f08c6b0000000000000000000000000000000000000000000000000000000000000001

<br />

### To Filter For The DepositContractCreated Topic

The `DepositContractCreated(address indexed depositContract, uint256 number)` event signature follows:

    > web3.sha3('DepositContractCreated(address,uint256)')
    "0x17b39befb027a95f2f3423ca18f3d98ce369297f24316ebfd763c3b543989477"

Example:

> {"address":"0xebb2634dd3194ba6d75eeb049cd0f73bf9801d95","blockHash":"0x028a9a4c7556b8f5b020e6b624673b78dd5fefa3730e8113e3896e57dd713dd0","blockNumber":10,"data":"0x0000000000000000000000000000000000000000000000000000000000000001","logIndex":0,"removed":false,"topics":["0x17b39befb027a95f2f3423ca18f3d98ce369297f24316ebfd763c3b543989477","0x000000000000000000000000**59da4a4d09575d187478f468ffda04fc1e8675aa**"],"transactionHash":"0x2ced2259477af3b351cd85932b62593dbb059af1734859760bceb6c29f4d705b","transactionIndex":0}
> {"address":"0xebb2634dd3194ba6d75eeb049cd0f73bf9801d95","blockHash":"0x33edb2eefee1a6009046a71c725b9e16b6a72298f160b7cc438127b4efbc4ad3","blockNumber":14,"data":"0x0000000000000000000000000000000000000000000000000000000000000002","logIndex":0,"removed":false,"topics":["0x17b39befb027a95f2f3423ca18f3d98ce369297f24316ebfd763c3b543989477","0x000000000000000000000000**7e3527064e2b1441956ed786ad58d18b9e3fcf10**"],"transactionHash":"0xa963e7556e522dfc21cf83d4041f761a5adf99b712c36e36770607ef4f59b0ff","transactionIndex":0}


In the event data above, the deposit accounts created `0x59da4a4d09575d187478f468ffda04fc1e8675aa` and `0x7e3527064e2b1441956ed786ad58d18b9e3fcf10` are encoded in the second `topics` parameter with 0 padding.


<br />

### To Filter For The DepositReceived Topic

The `DepositReceived(address indexed depositOrigin, address indexed depositContract, uint256 _value)` event signature follows:

    > web3.sha3('DepositReceived(address,address,uint256)')
    "0x54ef209e319f7d023f4f2c1d4b427c3844f7ef008d20a2104b1f20cb533a7fbf"

Example:

>  {"address":"0xebb2634dd3194ba6d75eeb049cd0f73bf9801d95","blockHash":"0x72543062997b246cebe37695f29e60f040f409272d84a8b654534faab00328d4","blockNumber":23,"data":"0x0000000000000000000000000000000000000000000000008e087d455911b400","logIndex":0,"removed":false,"topics":["0x54ef209e319f7d023f4f2c1d4b427c3844f7ef008d20a2104b1f20cb533a7fbf","0x000000000000000000000000**0055fbc1ada89056088c75eaf50400af6756ae61**","0x00000000000000000000000059da4a4d09575d187478f468ffda04fc1e8675aa"],"transactionHash":"0x74e2f1c380e1b4f02835bd69c33062a077d44c19f967588b8363e7a2ebdd6eae","transactionIndex":0}

In the event data above, the account depositing ethers `0x0055fbc1ada89056088c75eaf50400af6756ae61` is encoded in the second `topics` parameter with 0 padding.

<br />

### To Filter For The FundingClosed Topic

The `FundingClosed(bool fundingClosed)` event signature follows:

    > web3.sha3('FundingClosed(bool)')
    "0x128cd232a366068e71f466a5964eb7927d8feb552e077ff55849d447ebaf2392"

The first event has `fundingClosed` set to **true**
>  {"address":"0xebb2634dd3194ba6d75eeb049cd0f73bf9801d95","blockHash":"0x8501ac362baacbaf187aaf20806d2f4c46249c1225ccb08f1c5a76bdb736fbb6","blockNumber":31,"data":"0x000000000000000000000000000000000000000000000000000000000000000**1**","logIndex":0,"removed":false,"topics":["0x128cd232a366068e71f466a5964eb7927d8feb552e077ff55849d447ebaf2392"],"transactionHash":"0xea7f42f4868dd578e1920db96d4a9a97ad0a95ba0afa8e1bd2117ebabb8e8b9a","transactionIndex":0}

The second event has `fundingClosed` set to **false**
> {"address":"0xebb2634dd3194ba6d75eeb049cd0f73bf9801d95","blockHash":"0x631fe704069fb6e237a3e3a1b30745dfc895ba3c6466e96f7d1edcbbf8a6084f","blockNumber":35,"data":"0x000000000000000000000000000000000000000000000000000000000000000**0**","logIndex":0,"removed":false,"topics":["0x128cd232a366068e71f466a5964eb7927d8feb552e077ff55849d447ebaf2392"],"transactionHash":"0x780b519d25e1c431a0f7bd9c9740c7af97e0bbada0243b54ea810e85471f54bc","transactionIndex":0}


<br />

<hr />

## Testing And Results

The test cases can be found in [test/01_test1.sh](test/01_test1.sh) and the results from this test in [test/test1results.txt](test/test1results.txt).

<br />

<hr />

## Security Audit

You can find the security audit [here](SecurityAudit).

<br />

<hr />

## Deployment Checks

After deployment of the contract to the Ethereum blockchain, double check the configuration data - **DEPOSIT_DATE_FROM**, **DEPOSIT_DATE_TO**, **incentAccount**, **feeAccount** and **clientAccount**.

<br />

Enjoy. (c) Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017. The MIT Licence.
