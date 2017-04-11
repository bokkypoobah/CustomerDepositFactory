# Customer Deposit Factory

This is an Ethereum contract that allows unique deposit contracts to be created for customers to deposit funds for an ICO.

<br />

## JSON RPC Interaction With This Contract

### Creating New Deposit Contract Addresses

The `createDepositContracts(uint256 number)` function signature follows:

    > web3.sha3('createDepositContracts(uint256)').substring(0, 10)
    "0x15891148"

Append the 0 padded number of deposit contracts to be created, for example to create 20 deposit contracts:

    0x158911480000000000000000000000000000000000000000000000000000000000000014

### Set The Funding Closed Flag

The `setFundingClosed(bool _fundingClosed)` function signature follows:

    > web3.sha3('setFundingClosed(bool)').substring(0, 10)
    "0x84f08c6b"

Append the 0 padded boolean flag 0 (off) or 1 (on), for example to close off the funding:

    0x84f08c6b0000000000000000000000000000000000000000000000000000000000000001

### To Filter For The DepositContractCreated Topic

The `DepositContractCreated(address indexed depositContract, uint256 number)` event signature follows:

    > web3.sha3('DepositContractCreated(address,uint256)')
    "0x17b39befb027a95f2f3423ca18f3d98ce369297f24316ebfd763c3b543989477"


### To Filter For The DepositReceived Topic

The `DepositReceived(address indexed depositOrigin, address indexed depositContract, uint256 _value)` event signature follows:

    > web3.sha3('DepositReceived(address,address,uint256)')
    "0x54ef209e319f7d023f4f2c1d4b427c3844f7ef008d20a2104b1f20cb533a7fbf"

### To Filter For The FundingClosed Topic

The `FundingClosed(bool fundingClosed)` event signature follows:

    > web3.sha3('FundingClosed(bool)')
    "0x128cd232a366068e71f466a5964eb7927d8feb552e077ff55849d447ebaf2392"

<br />

## Testing And Results

The test cases can be found in [test/01_test1.sh](test/01_test1.sh) and the results from this test in [test/test1results.txt](test/test1results.txt).


Enjoy. (c) Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017. The MIT Licence.
