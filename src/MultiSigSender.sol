pragma solidity ^0.8.13;

contract MultiSigSender {
    // Signers
    address[] signers;

    // Spend transaction
    struct SpendTxn {
        address recipient;
        uint256 amount;
        mapping(address => bool) approvals;
        uint256 approvalCount;
    }

    // Spend transactions
    SpendTxn[]  private spendTransactions;

    

    constructor(address[] memory walletSigners) {
        require(walletSigners.length == 3);
        signers = walletSigners;
    }

    function  isSigner(address s)  view public returns (bool)  {
        return signers[0] == s || signers[1] == s 
        || signers[2] ==  s;
    }

    receive() external payable {
        require(msg.sender != address(this));
    }
    
    function submitSpend(address recipient, uint256 amount) public  {
        uint256 index = spendTransactions.length;

        // From certora counter example in spec 1
        require (recipient != address(this), "Cannot submit spend from contract to itself");
        require (recipient != address(0));
        // From certora counter example in spec 1
        require (amount > 0, "Spend of zero not allowed");

        spendTransactions.push();
        spendTransactions[index].recipient = recipient;
        spendTransactions[index].amount = amount;
    } 

    function approveSpend(uint256 transactionNo) public {
        SpendTxn storage txn = spendTransactions[transactionNo];
        txn.approvals[msg.sender] = true;
        txn.approvalCount += 1;
    }

    function executeTransaction(uint256 transactionNo) public {
        SpendTxn storage txn = spendTransactions[transactionNo];
        (bool success, ) = txn.recipient.call{value: txn.amount}("");
        require(success, "execute transaction failed");
    }

    function getRecipient(uint256 txnNo) view public returns (address)  {
        SpendTxn storage txn = spendTransactions[txnNo];
        return txn.recipient;
    }

    function getAmount(uint256 txnNo) view public returns (uint256)  {
        SpendTxn storage txn = spendTransactions[txnNo];
        return txn.amount;
    }

    function balanceOf(address a) view public returns (uint256) {
        return a.balance;
    }
}