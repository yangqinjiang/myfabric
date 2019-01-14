

# 创建channel
peer channel create -o orderer.qbgoo.com:7050 -c qbgoochannel -f ./channel-artifacts/channel.tx  \
--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/qbgoo.com/orderers/orderer.qbgoo.com/msp/tlscacerts/tlsca.qbgoo.com-cert.pem