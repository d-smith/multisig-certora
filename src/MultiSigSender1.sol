pragma solidity ^0.8.13;

contract MultiSigSender {
    // Const
    uint256 public constant THRESHOLD = 2;
    
    // Signers
    address[] signers;

    // Spend transaction
    struct SpendTxn {
        address recipient;
        uint256 amount;
        address submitter;
        address[] approvals;
        uint256 approvalCount;
    }

    // Spend transaction
    SpendTxn private spendTransaction;

    constructor(address[] memory walletSigners) {
        require(walletSigners.length == THRESHOLD + 1);
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
        require (recipient != address(this), "Cannot submit spend from contract to itself");
        require (recipient != address(0));
        require ( msg.sender != address(0));
        require (amount > 0, "Spend of zero not allowed");
        require (spendTransaction.submitter == address(0), "Cannot submit against until approved"); // run 1
        //TODO - add reset

        spendTransaction.submitter = msg.sender;        
        spendTransaction.recipient = recipient;
        spendTransaction.amount = amount;
    } 

    function approveSpend() public {
        require (spendTransaction.submitter != address(0), "Nothing to approve"); //  run 1
        spendTransaction.approvals.push(msg.sender);
    }

    function executeTransaction() public {
        (bool success, ) = spendTransaction.recipient.call{value: spendTransaction.amount}("");
        require(success, "execute transaction failed");
    }

    function getRecipient() view public returns (address)  {
        return spendTransaction.recipient;
    }

    function getAmount() view public returns (uint256)  {
        return spendTransaction.amount;
    }

    function getSubmitter() view public returns (address)  {
        return spendTransaction.submitter;
    }

    function balanceOf(address a) view public returns (uint256) {
        return a.balance;
    }

    function getApprovalCount() view public returns (uint256) {
        return spendTransaction.approvals.length;
    }
    
    function getSignatureThreshold() view public returns (uint256) {
        return THRESHOLD;
    }

}