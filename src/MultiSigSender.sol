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
    SpendTxn[] public spendTransactions;

    

    constructor(address[] memory walletSigners) {
        require(walletSigners.length == 3);
        signers = walletSigners;
    }

    function  isSigner(address s)  view public returns (bool)  {
        return signers[0] == s || signers[1] == s 
        || signers[2] ==  s;
    }

    receive() external payable {}
    
    function submitSpend(address recipient, uint256 amount) public  {
        uint256 index = spendTransactions.length;

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
}