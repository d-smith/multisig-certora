pragma solidity ^0.8.13;

contract MultiSigSender {
    // Const
    uint256 public constant THRESHOLD = 2;
    
    // Signers
    address[3] signers;

    // Spend transaction
    struct SpendTxn {
        address recipient;
        uint256 amount;
        address submitter;
        address[] approvals;
    }

    // Spend transaction
    SpendTxn private spendTransaction;

    constructor(address[] memory walletSigners) {
        require(walletSigners.length == THRESHOLD + 1);
        signers[0] = walletSigners[0];
        signers[1] = walletSigners[1];
        signers[2] = walletSigners[2];
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
        /// SwapArgumentsOperatorMutation of: require (amount > 0, "Spend of zero not allowed");
        require (0 > amount, "Spend of zero not allowed");
        require (spendTransaction.submitter == address(0), "Cannot submit against until approved");
        //TODO - add reset

        spendTransaction.submitter = msg.sender;        
        spendTransaction.recipient = recipient;
        spendTransaction.amount = amount;
    } 

    function approveSpend() public {
        require (spendTransaction.submitter != address(0), "Nothing to approve");
        require (isSigner(msg.sender), "Only signers may approve spend");
        require (spendTransaction.submitter != msg.sender, "Signer may not approve own spend");

        require(frequency(msg.sender) == 0, "Signer may only approve once");
        spendTransaction.approvals.push(msg.sender);
    }

    function frequency(address value) public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < spendTransaction.approvals.length; i++) {
            if  (spendTransaction.approvals[i] == value) 
                counter++;
        }
        return counter;
    }

    function executeTransaction() public {
        require(spendTransaction.approvals.length >= THRESHOLD, "Only fully approved transactions may be approved");
        require(isSigner(msg.sender), "Only signers may submit an approved transaction");
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

    function getApprover(uint i) view public returns (address) {
        return spendTransaction.approvals[i]; //reverts on index out of bounds
    }

    function getApproverWithDefaultValue(uint256 index) public view returns(address){
        if (index < spendTransaction.approvals.length)
        {
            return spendTransaction.approvals[index];
        }
        return address(0);
    }

}
