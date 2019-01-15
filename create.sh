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

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="mychannel"}

echo "===================== '通道名称: $CHANNEL_NAME' ===================== "
# Generates Org certs using cryptogen tool
generateCerts(){
    echo "##########################################################"
    echo "################### 使用cryptogen生成证书 #################"
    echo "##########################################################"
    which cryptogen
    if [ "$?" -ne 0 ]; then
        echo "cryptogen tool not found. exiting"
        exit 1
    fi
    cryptoConfigDir=crypto-config

    if [ -d $cryptoConfigDir ]; then
        echo "强制删除${cryptoConfigDir}目录"
        rm -Rf $cryptoConfigDir
    fi
    set -x
    # 根据指定的模板在指定目录下生成证书
    cryptogen generate --config=crypto-config.yaml --output $cryptoConfigDir
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi
    echo
}

generateCerts

echo "===================== 生成的创始块和通道文件 ===================== "
#将生成的创始块和通道文件存储在该目录中
channelArtifactsDir=channel-artifacts



# 1. 在项目根目录下创建新目录 $channelArtifactsDir, 
# 将生成的创始块和通道文件存储在该目录中
[ ! -d  $channelArtifactsDir ] && mkdir $channelArtifactsDir

echo "===================== 创始块文件 ===================== "
# 生成创始块文件
configtxgen   -profile OrgsOrdererGenesis -outputBlock $channelArtifactsDir/${CHANNEL_NAME}_genesis.block


echo "===================== 创建channel.tx文件 ===================== "
# 创建channel
# channel.tx中包含了用于生产channel的信息
configtxgen  -profile OrgsChannel -outputCreateChannelTx ./$channelArtifactsDir/${CHANNEL_NAME}_channel.tx -channelID $CHANNEL_NAME

echo "===================== 生成相关的锚点文件 - 组织A ===================== "
# 生成相关的锚点文件 - 组织A
configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OrgAMSP
echo "===================== 生成相关的锚点文件 - 组织B ===================== "
# 生成相关的锚点文件 - 组织B
configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgBMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OrgBMSP
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
