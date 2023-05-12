using MultiSigSender as mss

methods {
    getRecipient(uint256) returns (address) envfree
    balanceOf(address a) returns (uint256) envfree
    getAmount(uint256 txnNo) returns (uint256)  envfree
}


rule balanceChangesFromCertainFunctions(method f, uint256 txnNo){
    env e;
    calldataarg args;
    mathint userBalanceBefore = balanceOf(mss);
    f(e, args);
    mathint userBalanceAfter = balanceOf(mss);

    assert userBalanceBefore != userBalanceAfter => 
        (f.selector == executeTransaction(uint256).selector ) ||
        (f.isFallback),
         "user's balance changed as a result function other than executeTransaction() or receive()";
}

