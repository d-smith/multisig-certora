certoraRun src/MultiSigSender2.sol:MultiSigSender --verify MultiSigSender:multiSigSender2.spec \
--solc solc8.13 \
--optimistic_loop \
--send_only \
--msg "$1"
