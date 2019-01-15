#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo

channelName="$1"
: ${CHANNEL_NAME:="mychannel"}
echo "===================== '通道名称: $channelName' ===================== "


echo "===================== 生成证书 ===================== "
# 根据默认模板在对应目录下生成证书
cryptogen generate
# 根据指定的模板在指定目录下生成证书
cryptogen generate --config=crypto-config.yaml --output crypto-config

echo "===================== 生成的创始块和通道文件 ===================== "
#将生成的创始块和通道文件存储在该目录中
channelArtifactsDir=channel-artifacts




# 1. 在项目根目录下创建新目录 $channelArtifactsDir, 
# 将生成的创始块和通道文件存储在该目录中
[ ! -d  $channelArtifactsDir ] && mkdir $channelArtifactsDir

echo "===================== 创始块文件 ===================== "
# 生成创始块文件
configtxgen   -profile OrgsOrdererGenesis -outputBlock $channelArtifactsDir/genesis.block


echo "===================== 创建channel.tx文件 ===================== "
# 创建channel
# channel.tx中包含了用于生产channel的信息
configtxgen  -profile OrgsChannel -outputCreateChannelTx ./$channelArtifactsDir/$channelName_channel.tx -channelID $channelName

echo "===================== 生成相关的锚点文件 - 组织A ===================== "
# 生成相关的锚点文件 - 组织A
configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgAMSPanchors.tx -channelID $channelName -asOrg OrgAMSP
echo "===================== 生成相关的锚点文件 - 组织B ===================== "
# 生成相关的锚点文件 - 组织B
configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgBMSPanchors.tx -channelID $channelName -asOrg OrgBMSP
#查看$channelArtifactsDir目录下生成的文件

tree $channelArtifactsDir/

echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0



#-------------------------------
# 创建channel
# peer channel create -o orderer.qbgoo.com:7050 -c $channelName -f ./$channelArtifactsDir/channel.tx  \
# --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/qbgoo.com/orderers/orderer.qbgoo.com/msp/tlscacerts/tlsca.qbgoo.com-cert.pem