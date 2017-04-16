# Security Audit Of The CustomerDepositFactory Smart Contract

The CustomerDepositFactory smart contract allows Incent Loyalty to create a series of uniquely addressed deposit contracts on the Ethereum blockchain. Each of these deposit contracts can be provided to customers and when customers send ethers to their deposit contract, their ethers will be split via the factory contract in a 0.5%/0.5%/99% ratio into 3 Ethereum addresses.

This report is a security audit of the CustomerDepositFactory smart contract.

<br />

<hr />

**Table of contents**
* [Background And History](#background-and-history)
* [Security Overview Of The CustomerDepositFactory](#security-overview-of-the-customerdepositfactory)
  * [Other Notes](#other-notes)
* [Comments On The Source Code](#comments-on-the-source-code)
* [References](#references)

<br />

<hr />

## Background And History
* Apr 11 2017 CustomerDepositFactory contract completed for Incent Loyalty
* Apr 11 2017 Bok Consulting completed the test script [test/01_test1.sh](test/01_test1.sh) with the generated result documented in [test/test1results.txt](test/test1results.txt)
* Apr 16 2017 Bok Consulting completed this security audit report

<br />

## Security Overview Of The CustomerDepositFactory
* [x] The smart contract has been kept relatively simple
* [x] This smart contract does not accumulate deposits of ethers but just passes these amounts to 3 different addresses
* [x] The code has been tested for the normal use cases, and around the boundary cases
* [x] The testing has been done using geth 1.5.9-stable and solc 0.4.9+commit.364da425.Darwin.appleclang instead of one of the testing frameworks and JavaScript VMs to simulate the live environment as closely as possible
* [x] `factory.receiveDeposit.value(msg.value)(msg.sender)` is used to pass ethers from the customer's deposit contract to the factory contract. As the factory contract is trusted, and the 3 destination addresses are trusted, there is little security risk of using this call method.
* [x] The `send(...)` call has been used instead of `call.value()()` for transferring funds with limited gas from the factory contract to the 3 trusted destination addresses.
* [x] The `send(...)` calls are the last statements in the control flow to prevent the hijacking of the control flow, but the 3 destination addresses are trusted
* [x] The return status from `send(...)` calls are all checked and invalid results will **throw** 
* [x] There is no logic with potential division by zero errors
* [x] All numbers used are uint256, reducting the risk of errors from type conversions
* [x] There is no logic with potential overflow errors, as the numbers added are taken from the value of ethers sent in each transaction, this value is validated as part of the sent transactions and these values are small compared to the uint256 limits
* [x] There is no logic with potential underflow errors. While there are some subtractions used in this code, the range of numbers is limited by the values being a known factor of `msg.value`
* [x] Function and event names are differentiated by case - function names begin with a lowercase character and event names begin with an uppercase character

### Other Notes
* Ethers and ERC20 tokens can get trapped in this contract
* While the CustomerDepositFactory Solidity code logic has been audited, there are small possibilities of errors that could compromise the security of this contract. This includes errors in the Solidity to bytecode compilation, errors in the execution of the VM code, or security failures in the Ethereum blockchain
  * For example see [Security Alert – Solidity – Variables can be overwritten in storage](https://blog.ethereum.org/2016/11/01/security-alert-solidity-variables-can-overwritten-storage/)
* There is the possibility of a miner mining a block and skewing the `now` timestamp. This can result valid customer deposits being rejected and invalid customer deposits being accepted, and this would be most relevant at the end of the deposit period
* If possible, run a [bug bounty program](https://github.com/ConsenSys/smart-contract-best-practices#bug-bounty-programs) on this contract code
* All of the code, the testing and the security audit were conducted by the same individual, BokkyPooBah / Bok Consulting, and this is a potential conflict of interest

<br />

## Comments On The Source Code

My comments in the following code are marked in the lines beginning with `// NOTE: `

```javascript
pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------
// Unique deposit contacts for customers to deposit ethers that are sent to 
// different wallets
//
// A collaboration between Incent and Bok :)
//
// Enjoy. (c) Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017. 
// The MIT Licence.
// ----------------------------------------------------------------------------

contract Config {

    // NOTE: 1. Make sure that this number is double checked to confirm
    //          that the correct date is used
    //
    // Cannot receive funds before this date. DO NOT USE `now`
    uint256 public constant DEPOSIT_DATE_FROM = {{DEPOSIT_DATE_FROM}};

    // NOTE: 1. Make sure that this number is double checked to confirm
    //          that the correct date is used
    //
    // Cannot receive funds after this date. DO NOT USE `now`
    uint256 public constant DEPOSIT_DATE_TO = {{DEPOSIT_DATE_TO}};

    // Incent account - 0.5%
    uint256 public constant INCENT_RATE_PER_THOUSAND = 5;
    address public incentAccount = {{INCENTACCOUNT}};

    // Fees - 0.5%
    uint256 public constant FEE_RATE_PER_THOUSAND = 5;
    address public constant feeAccount = {{FEEACCOUNT}};

    // Client account - remainder of sent amount
    address public constant clientAccount = {{CLIENTACCOUNT}};
}

// NOTE: 1. Standard Owned contract, with the owner set in the constructor
//
contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// NOTE: 1. Customer deposit contract where different contracts are assigned to different users
//
contract CustomerDeposit {
    uint256 public totalDeposit = 0;
    CustomerDepositFactory public factory;

    function CustomerDeposit(CustomerDepositFactory _factory) {
        factory = _factory;
    }

    function () payable {
        totalDeposit += msg.value;
        factory.receiveDeposit.value(msg.value)(msg.sender);
    }
}

contract CustomerDepositFactory is Owned, Config {
    uint256 public totalDeposits = 0;
    bool public fundingClosed = false;
    CustomerDeposit[] public depositContracts;
    mapping (address => bool) public isDepositContract;

    modifier fundingPeriodActive() {
        if (now < DEPOSIT_DATE_FROM || now > DEPOSIT_DATE_TO) throw;
        _;
    }

    event DepositContractCreated(address indexed depositContract, uint256 number);
    event DepositReceived(address indexed depositOrigin, 
        address indexed depositContract, uint256 _value);
    event FundingClosed(bool fundingClosed);

    function createDepositContracts(uint256 number) onlyOwner {
        for (uint256 i = 0; i < number; i++) {
            CustomerDeposit customerDeposit = new CustomerDeposit(this);
            depositContracts.push(customerDeposit);
            isDepositContract[customerDeposit] = true;
            DepositContractCreated(customerDeposit, depositContracts.length);
        }
    }

    function numberOfDepositContracts() constant returns (uint) {
        return depositContracts.length;
    }

    function receiveDeposit(address depositOrigin) fundingPeriodActive payable {
        // Can only receive ethers from deposit contracts created by this factory
        if (!isDepositContract[msg.sender]) throw;

        // Don't accept ethers from deposit contracts after the funding is closed
        if (fundingClosed) throw;

        // Record total deposits
        totalDeposits += msg.value;

        // Send amount to incent address
        uint256 value1 = msg.value * INCENT_RATE_PER_THOUSAND / 1000;
        if (!incentAccount.send(value1)) throw;

        // Send fee to the fee address
        uint256 value2 = msg.value * FEE_RATE_PER_THOUSAND / 1000;
        if (!feeAccount.send(value2)) throw;

        // Send the remainder to the client's wallet
        uint256 value3 = msg.value - value1 - value2;
        if (!clientAccount.send(value3)) throw;

        DepositReceived(depositOrigin, msg.sender, msg.value);
    }

    // Set to true when funding is completed. No more more deposits will be 
    // accepted
    function setFundingClosed(bool _fundingClosed) onlyOwner {
      fundingClosed = _fundingClosed;
      FundingClosed(fundingClosed);
    }

    // Prevent accidental sending of ethers to the factory
    function () {
        throw;
    }
}
```

<br />

## References

* [Ethereum Contract Security Techniques and Tips](https://github.com/ConsenSys/smart-contract-best-practices)

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd - Apr 16 2017