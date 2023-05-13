using MultiSigSender as mss

methods {
    getRecipient() returns (address) envfree
    balanceOf(address a) returns (uint256) envfree
    getAmount() returns (uint256)  envfree
    getSubmitter() returns (address) envfree
    getApprovalCount() returns (uint256) envfree
    getSignatureThreshold() returns (uint256) envfree
    isSigner(address) returns (bool) envfree
}

// Define vallid states - awaiting transaction, waiting on approvals, spend approved
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

// Define invariant: the system is always in a valid start
invariant validStates()
    awaitTransaction() && !waitingApproval() && !spendApproved()
    || !awaitTransaction() && waitingApproval() && !spendApproved()
    || !awaitTransaction() && !waitingApproval() && spendApproved()

// Todo - add rules that define valid state transition, for example await transaction transition
// to waiting approval may only occur after submitTransactions is called

// Rule: only signers may approved transactions, and not transactions they submitted
rule signersApprove() {
    env e;
    approveSpend@withrevert(e);
    assert !lastReverted => isSigner(e.msg.sender) && getSubmitter() != e.msg.sender;
}