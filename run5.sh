certoraRun src/MultiSigSender4.sol:MultiSigSender --verify MultiSigSender:multiSigSender5.spec \
--solc solc8.13 \
--optimistic_loop \
--send_only \
--msg "$1"
