#将生成的创始块和通道文件存储在该目录中
channelArtifactsDir=../channel-artifacts
channelName=qbgoochannel



# 1. 在项目根目录下创建新目录 $channelArtifactsDir, 
# 将生成的创始块和通道文件存储在该目录中
[ ! -d  $channelArtifactsDir ] && mkdir $channelArtifactsDir


# 生成创始块文件
configtxgen -configPath=../  -profile OrgsOrdererGenesis -outputBlock $channelArtifactsDir/genesis.block


# # 创建channel
# # channel.tx中包含了用于生产channel的信息
# configtxgen  -profile OrgsChannel -outputCreateChannelTx ./$channelArtifactsDir/channel.tx -channelID $channelName

# # 生成相关的锚点文件 - 组织A
# configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgAMSPanchors.tx -channelID $channelName -asOrg OrgAMSP
# # 生成相关的锚点文件 - 组织B
# configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgBMSPanchors.tx -channelID $channelName -asOrg OrgBMSP
# #查看$channelArtifactsDir目录下生成的文件
# tree $channelArtifactsDir/





#-------------------------------
# 创建channel
# peer channel create -o orderer.qbgoo.com:7050 -c $channelName -f ./$channelArtifactsDir/channel.tx  \
# --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/qbgoo.com/orderers/orderer.qbgoo.com/msp/tlscacerts/tlsca.qbgoo.com-cert.pem