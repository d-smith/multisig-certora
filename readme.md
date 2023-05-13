# MultiSig and Certora 

This is a simple project for getting familiar with Certora, starting with a 2 of 3 
multisignature threshold before sending an amount of ether.

Along the way I've tried to capture the progression of the specification against
an initial minimal cut the contract.

* run0 is against the first cut with rules that define the states the contract can be in. This will generate counter examples.
* run1 is the first cut with enough added to at least ensure only valid states are possible
* run2 - only signers may approve, may not approve your own spend

