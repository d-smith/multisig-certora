using MultiSigSender as mss

methods {
    getRecipient() returns (address) envfree
    balanceOf(address a) returns (uint256) envfree
    getAmount() returns (uint256)  envfree
    getSubmitter() returns (address) envfree
    getApprovalCount() returns (uint256) envfree
    getSignatureThreshold() returns (uint256) envfree

}

// States - awaiting transaction, waiting on approvals, spend approved
definition awaitTransaction() returns bool = 
    getRecipient() == 0 &&
    getSubmitter() == 0 &&
    getAmount() == 0 &&
    getApprovalCount() == 0;

definition waitingApproval() returns bool = 
    getRecipient() != 0 &&
    getSubmitter() != 0 &&
    getAmount() > 0 &&
    getApprovalCount() < getSignatureThreshold();

definition spendApproved() returns bool = 
    getRecipient() != 0 &&
    getSubmitter() != 0 &&
    getAmount() > 0 &&
    getApprovalCount() >= getSignatureThreshold();

    
invariant validStates()
    awaitTransaction() && !waitingApproval() && !spendApproved()
    || !awaitTransaction() && waitingApproval() && !spendApproved()
    || !awaitTransaction() && !waitingApproval() && spendApproved()
