pragma solidity ^0.4.8;
 
// ----------------------------------------------------------------------------------------------
// Unique deposit contacts for customers to deposit ethers that are sent to different wallets
//
// Enjoy. (c) Bok Consulting Pty Ltd & Incent Rewards 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------
 
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
    uint256 public totalDeposit;
    CustomerDepositFactory public factory;
 
    function CustomerDeposit(CustomerDepositFactory _factory) {
        factory = _factory;
    }
 
    function () payable {
        totalDeposit += msg.value;
        factory.receiveDeposit.value(msg.value)();
    }
}

contract CustomerDepositFactory is Owned {
    uint256 public totalDeposits = 0;
    CustomerDeposit[] public addresses;
    mapping (address => bool) public check;

    // NOTE: Remix is not handling indexed addresses 
    event DepositContractCreated(uint256 number, address icoDepositContract);
    event DepositReceived(address icoDepositContract, uint _value);
 
    // Define destination addresses
    // 0.5%
    address public constant incentToCustomer = 0xa5f93F2516939d592f00c1ADF0Af4ABE589289ba;
    // 0.5%
    address public constant icoFees = 0x38671398aD25461FB446A9BfaC2f4ED857C86863;
    // 99%
    address public constant icoClientWallet = 0x994B085D71e0f9a7A36bE4BE691789DBf19009c8;
 
    function createDepositContracts(uint256 number) onlyOwner {
        for (uint256 i = 0; i < number; i++) {
            CustomerDeposit customerDeposit = new CustomerDeposit(this);
            addresses.push(customerDeposit);
            check[customerDeposit] = true;
            DepositContractCreated(addresses.length, customerDeposit);
        }
    }
 
    function receiveDeposit() payable {
        if (!check[msg.sender]) throw;
        totalDeposits += msg.value;
        uint256 value1 = msg.value * 1 / 200;
        if (!incentToCustomer.send(value1)) throw;
        uint256 value2 = msg.value * 1 / 200;
        if (!icoFees.send(value2)) throw;
        uint256 value3 = msg.value - value1 - value2;
        if (!icoClientWallet.send(value3)) throw;
        DepositReceived(msg.sender, msg.value);
    }
 
    // Prevent accidental sending of ethers
    function () {
        throw;
    }
}
