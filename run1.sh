certoraRun src/MultiSigSender1.sol:MultiSigSender --verify MultiSigSender:multiSigSender1.spec \
--solc solc8.13 \
--optimistic_loop \
--send_only \
--msg "$1"
