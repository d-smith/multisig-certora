using MultiSigSender as mss

methods {
    getRecipient() returns (address) envfree
    balanceOf(address a) returns (uint256) envfree
    getAmount() returns (uint256)  envfree
    getSubmitter() returns (address) envfree
    getApprovalCount() returns (uint256) envfree
    getSignatureThreshold() returns (uint256) envfree
    isSigner(address) returns (bool) envfree
    getApproverWithDefaultValue(uint256) returns (address) envfree
    frequency(address) returns (uint) envfree
    getApprover(uint) returns (address) envfree
}

// Define valid states - awaiting transaction, waiting on approvals, spend approved
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

// Invariant - unique approvers
invariant frequencyLessThenTwo(address a)
    frequency(a) < 2

invariant uniqueArraySolution(uint256 i, uint256 j)
    i != j => (
        (getApproverWithDefaultValue(i) != getApproverWithDefaultValue(j)) || 
		((getApproverWithDefaultValue(i) == 0) && (getApproverWithDefaultValue(j) == 0)))
    {
        preserved{
            requireInvariant frequencyLessThenTwo(getApprover(i));
            requireInvariant frequencyLessThenTwo(getApprover(j));
        }
    }

// Rule - transactions may only be submitted after the number of signatures meets the threshold, and
// only by signers
rule executionRequiredFullApproval() {
    env e;
    executeTransaction@withrevert(e);
    assert !lastReverted => getApprovalCount() >= getSignatureThreshold() && isSigner(e.msg.sender);   
}

rule waitForApprovalsFollowsTransactionSubmit(method f) {
    env e;
    calldataarg args;

    bool awaitingTxnBefore;
    bool awaitingApprovalsAfter;

    awaitingTxnBefore  = awaitTransaction();
    f(e, args);
    awaitingApprovalsAfter = waitingApproval();

    assert ((awaitingTxnBefore == true &&  awaitingApprovalsAfter == true) => f.selector == submitSpend(address,uint256).selector);
}

