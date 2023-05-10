certoraRun src/MultiSigSender.sol --verify MultiSigSender:multiSigSender1.spec \
--solc solc8.13 \
--optimistic_loop \
--send_only \
--msg "$1"
