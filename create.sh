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
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
# default for delay between commands
CLI_DELAY=3
# use this as the default docker-compose yaml definition
COMPOSE_FILE=docker-compose.yaml
#
# use golang as the default language for chaincode
LANGUAGE=golang
VERBOSE=false
# default image tag
IMAGETAG="latest"

echo "===================== '通道名称: $CHANNEL_NAME' ===================== "
# Generates Org certs using cryptogen tool
#使用cryptogen生成证书
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
    tree $cryptoConfigDir/ -L 3
}

#生成的创始块和通道文件
generateChannelArtifacts() {
    echo "##########################################################"
    echo "################  生成的创始块和通道文件 ###################"
    echo "##########################################################"
    which configtxgen
    if [ "$?" -ne 0 ]; then
        echo "configtxgen tool not found. exiting"
        exit 1
    fi
    
    #将生成的创始块和通道文件存储在该目录中
    channelArtifactsDir=channel-artifacts
    if [ -d $channelArtifactsDir ]; then
        echo "强制删除${channelArtifactsDir}目录"
        rm -Rf $channelArtifactsDir
    fi


    # 1. 在项目根目录下创建新目录 $channelArtifactsDir, 
    # 将生成的创始块和通道文件存储在该目录中
    [ ! -d  $channelArtifactsDir ] && mkdir $channelArtifactsDir

    echo "===================== 创始块文件 ===================== "
    # 生成创始块文件
    set -x
    configtxgen   -profile OrgsOrdererGenesis -outputBlock $channelArtifactsDir/${CHANNEL_NAME}_genesis.block
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate orderer genesis block..."
      exit 1
    fi

    echo "===================== 创建channel.tx文件 ===================== "
    # 创建channel
    # channel.tx中包含了用于生产channel的信息
    set -x
    configtxgen  -profile OrgsChannel -outputCreateChannelTx ./$channelArtifactsDir/${CHANNEL_NAME}_channel.tx -channelID $CHANNEL_NAME
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate channel configuration transaction..."
      exit 1
    fi
    echo "===================== 生成相关的锚点文件 - 组织A ===================== "
    # 生成相关的锚点文件 - 组织A
    set -x
    configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgAMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OrgAMSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate anchor peer update for OrgAMSP..."
      exit 1
    fi
    echo "===================== 生成相关的锚点文件 - 组织B ===================== "
    # 生成相关的锚点文件 - 组织B
    set -x
    configtxgen  -profile OrgsChannel -outputAnchorPeersUpdate ./$channelArtifactsDir/OrgBMSPanchors.tx -channelID $CHANNEL_NAME -asOrg OrgBMSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
      echo "Failed to generate anchor peer update for OrgBMSP..."
      exit 1
    fi
    #查看$channelArtifactsDir目录下生成的文件
    echo "====================查看$channelArtifactsDir目录下生成的文件=============="

    tree $channelArtifactsDir/
}

networkUp(){
    echo "##########################################################"
    echo "################  docker-compose启动相关容器 ##############"
    echo "##########################################################"
    if [ -d $COMPOSE_FILE ]; then
        echo "不存在 ${COMPOSE_FILE} 文件,启动不了容器"
        exit 1
    fi
    set -x
    docker-compose -f $COMPOSE_FILE up -d 2>&1
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "ERROR !!!! Unable to start network,docker-compose ERROR"
        exit 1
    fi
    # 运行cli容器内的脚本
    # now run the end to end script
    docker exec cli scripts/script.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE
    if [ $? -ne 0 ]; then
      echo "ERROR !!!! Test failed"
      exit 1
    fi
}

# Print the usage message
printHelp() {
  echo "Usage: "
  echo "  byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-i <imagetag>] [-v]"
  echo "    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'upgrade'  - upgrade the network from version 1.1.x to 1.2.x"
  echo "    -c <channel name> - channel name to use (defaults to \"mychannel\")"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l <language> - the chaincode language: golang (default) or node"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
  echo "    -v - verbose mode"
  echo "  byfn.sh -h (print this message)"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	byfn.sh generate -c mychannel"
  echo "	byfn.sh up -c mychannel -s couchdb"
  echo "        byfn.sh up -c mychannel -s couchdb -i 1.2.x"
  echo "	byfn.sh up -l node"
  echo "	byfn.sh down -c mychannel"
  echo "        byfn.sh upgrade -c mychannel"
  echo
  echo "Taking all defaults:"
  echo "	byfn.sh generate"
  echo "	byfn.sh up"
  echo "	byfn.sh down"
}
MODE=$1
echo "参数1:${MODE}"
shift
#Create the network using docker compose
if [ $MODE == "up" ]; then
  networkUp
# elif [ $MODE == "down" ]; then ## Clear the network
#   #networkDown
#   printHelp
#   exit 1
# elif [ $MODE == "generate" ]; then ## Generate Artifacts
#   generateCerts
#   #replacePrivateKey
#   generateChannelArtifacts
# elif [ $MODE == "restart" ]; then ## Restart the network
#   #networkDown
#   #networkUp
#   printHelp
#   exit 1
# elif [ $MODE == "upgrade" ]; then ## Upgrade the network from version 1.1.x to 1.2.x
#   #upgradeNetwork
#   printHelp
#   exit 1
else
  printHelp
  exit 1
fi



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
