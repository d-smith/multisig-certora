certoraRun src/MultiSigSender3.sol:MultiSigSender --verify MultiSigSender:multiSigSender3.spec \
--solc solc8.13 \
--optimistic_loop \
--send_only \
--msg "$1"
