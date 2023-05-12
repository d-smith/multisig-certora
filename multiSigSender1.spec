using MultiSigSender as mss

rule balancesAfterSend(uint256 txnNo) {
    env e;

    uint256 balanceSenderBefore = balanceOf(e,mss);
    address recipient = getRecipient(e,txnNo);
	uint256 balanceRecipientBefore = balanceOf(e,recipient);
    executeTransaction(e, txnNo);
    uint256 balanceSenderAfter = balanceOf(e,mss);
	uint256 balanceRecipientAfter =  balanceOf(e,recipient);

    assert balanceRecipientBefore + balanceSenderBefore == balanceRecipientAfter + balanceSenderAfter, "the total funds before and after a transfer should remain the constant";
}

rule balanceChangesFromCertainFunctions(method f, uint256 txnNo){
    env e;
    calldataarg args;
    uint256 userBalanceBefore = balanceOf(e,mss);
    f(e, args);
    uint256 userBalanceAfter = balanceOf(e,mss);

    assert userBalanceBefore != userBalanceAfter => 
        (f.selector == executeTransaction(uint256).selector ),
         "user's balance changed as a result function other than transfer(), transferFrom(), mint() or burn()";
}

