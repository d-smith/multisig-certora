using MultiSigSender as mss

rule balancesAfterSend(uint256 txnNo) {
    env e;

    uint256 balanceSenderBefore = mss.balance;
    address recipient = getRecipient(e,txnNo);
	uint256 balanceRecipientBefore = balance(recipient);
    executeTransaction(e, txnNo);
    uint256 balanceSenderAfter = mss.balance;
	uint256 balanceRecipientAfter = recipient.balance;

    assert balanceRecipientBefore + balanceSenderBefore == balanceRecipientAfter + balanceSenderAfter, "the total funds before and after a transfer should remain the constant";
}