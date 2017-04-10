pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------------------------
// Unique deposit contacts for customers to deposit ethers that are sent to different wallets
//
// Enjoy. (c) Bok Consulting Pty Ltd & Incent Rewards 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------

contract Config {
    // Cannot receive funds before this date. DO NOT USE `now`
    uint256 public constant DEPOSIT_DATE_FROM = 1491553792;

    // Cannot receive funds after this date. DO NOT USE `now`
    uint256 public constant DEPOSIT_DATE_TO = 1491553912;

    // Incent account - 0.5%
    uint256 public constant INCENT_RATE_PER_THOUSAND = 5;
    address public incentAccount = 0x0020017ba4c67f76c76b1af8c41821ee54f37171;

    // Fees - 0.5%
    uint256 public constant FEE_RATE_PER_THOUSAND = 5;
    address public constant feeAccount = 0x0036f6addb6d64684390f55a92f0f4988266901b;

    // Client account - remainder of sent amount
    address public constant clientAccount = 0x004e64833635cd1056b948b57286b7c91e62731c;
}

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

    // NOTE: Remix does not handle indexed addresses correctly
    event DepositContractCreated(address indexed depositContract, uint256 number);
    event DepositReceived(address indexed depositOrigin, address indexed depositContract, uint _value);
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

    // Set to true when funding is completed. No more more deposits will be accepted
    function setFundingClosed(bool _fundingClosed) onlyOwner {
      fundingClosed = _fundingClosed;
      FundingClosed(fundingClosed);
    }

    // Prevent accidental sending of ethers to the factory
    function () {
        throw;
    }
}
