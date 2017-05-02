#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Unique deposit contacts for customers to deposit ethers that are sent to 
# different wallets - create new addresses
#
# A collaboration between Incent and Bok :)
# Enjoy. (c) Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

geth attach rpc:http://localhost:8545 << EOF | grep "RESULT: " | sed "s/RESULT: //"

var contractAbi=[{"constant":true,"inputs":[],"name":"FEE_RATE_PER_THOUSAND","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"number","type":"uint256"}],"name":"createDepositContracts","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"fundingClosed","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"isDepositContract","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"depositOrigin","type":"address"}],"name":"receiveDeposit","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[],"name":"INCENT_RATE_PER_THOUSAND","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"feeAccount","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalDeposits","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"depositContracts","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_fundingClosed","type":"bool"}],"name":"setFundingClosed","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"numberOfDepositContracts","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"clientAccount","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DEPOSIT_DATE_TO","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"incentAccount","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"DEPOSIT_DATE_FROM","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"payable":false,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"depositContract","type":"address"},{"indexed":false,"name":"number","type":"uint256"}],"name":"DepositContractCreated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"depositOrigin","type":"address"},{"indexed":true,"name":"depositContract","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"DepositReceived","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"fundingClosed","type":"bool"}],"name":"FundingClosed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"}],"name":"OwnershipTransferred","type":"event"}];
var contractAddress="0x48c398e79a2a144471b545319ea48d82b812087a";

function printContractStaticDetails() {
  var contract = eth.contract(contractAbi).at(contractAddress);
  var depositDateFrom = contract.DEPOSIT_DATE_FROM();
  console.log("RESULT: contract.depositDateFrom=" + depositDateFrom + " " + new Date(depositDateFrom * 1000));
  var depositDateTo = contract.DEPOSIT_DATE_TO();
  console.log("RESULT: contract.depositDateTo=" + depositDateTo + " " + new Date(depositDateTo * 1000));
  var incentRatePerThousand = contract.INCENT_RATE_PER_THOUSAND();
  console.log("RESULT: contract.incentRatePerThousand=" + incentRatePerThousand);
  var incentAccount = contract.incentAccount();
  console.log("RESULT: contract.incentAccount=" + incentAccount);
  var feeRatePerThousand = contract.FEE_RATE_PER_THOUSAND();
  console.log("RESULT: contract.feeRatePerThousand=" + feeRatePerThousand);
  var feeAccount = contract.feeAccount();
  console.log("RESULT: contract.feeAccount=" + feeAccount);
  var clientAccount = contract.clientAccount();
  console.log("RESULT: contract.clientAccount=" + clientAccount);
}

function printContractDynamicDetails() {
  var i;
  var contract = eth.contract(contractAbi).at(contractAddress);
  var numberOfDepositContracts = contract.numberOfDepositContracts();
  console.log("RESULT: contract.numberOfDepositContracts=" + numberOfDepositContracts);
  for (i = 0; i < numberOfDepositContracts; i++) {
    console.log("RESULT: contract.depositContracts(" + i + ") " + contract.depositContracts(i))
  }
  var totalDeposits = contract.totalDeposits();
  console.log("RESULT: contract.totalDeposits=" + web3.fromWei(totalDeposits, "ether"));
  var depositContractCreatedEvent = contract.DepositContractCreated({}, { fromBlock: 3572865, toBlock: "latest" });
  i = 0;
  depositContractCreatedEvent.watch(function (error, result) {
    console.log("RESULT: DepositContractCreated Event " + i++ + ": " + result.args.depositContract + " " + result.args.number +
      " block " + result.blockNumber);
  });
  depositContractCreatedEvent.stopWatching();
  var depositReceivedEvent = contract.DepositReceived({}, { fromBlock: 3572865, toBlock: "latest" });
  i = 0;
  depositReceivedEvent.watch(function (error, result) {
    console.log("RESULT: DepositReceived Event " + i++ + ": " + result.args.depositOrigin + " " + result.args.depositContract +
      " " + web3.fromWei(result.args._value, "ether") + " ETH block " + result.blockNumber);
    // console.log("RESULT: DepositReceived Event " + i++ + ": " + JSON.stringify(result));
  });
  depositReceivedEvent.stopWatching();
}

function printAddresses() {
  console.log("RESULT: customerDepositFactoryAddress=" + contractAddress);
  var i;
  var contract = eth.contract(contractAbi).at(contractAddress);
  var numberOfDepositContracts = contract.numberOfDepositContracts();
  console.log("RESULT: contract.numberOfDepositContracts=" + numberOfDepositContracts);
  console.log("RESULT: printing from 1220");
  console.log("RESULT: (");
  for (i = 1220; i < numberOfDepositContracts; i++) {
    console.log("RESULT: '" + contract.depositContracts(i) + "',");
  }
  console.log("RESULT: );");
}

// printContractStaticDetails();
// printContractDynamicDetails();

printAddresses();

EOF
