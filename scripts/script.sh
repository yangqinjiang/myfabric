#!/bin/bash

# 本脚本将在 cli 容器内运行
# 使用方式:
# docker exec cli scripts/script.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="qbgoochannel"}  #默认值
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
#链代码的路径
CC_SRC_PATH="github.com/chaincode/example02/go/"
# nodejs目录
# if [ "$LANGUAGE" = "node" ]; then
# 	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
# fi

echo "Channel name : "$CHANNEL_NAME

# 导入 utils.sh的函数,变量等等
# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 'A'

	# 是否开启TLS
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
		peer channel create -o orderer.qbgoo.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/qbgoochannel_channel.tx >&log.txt
		res=$?
        set +x
	else
		set -x
		peer channel create -o orderer.qbgoo.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/qbgoochannel_channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
		set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed" #检查命令的执行结果
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

# 加入通道
joinChannel () {
	# 遍历加入通道
	for org in 'A' 'B'; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}
## 创建通道
## Create channel
echo "Creating channel..."
createChannel

### 加入通道
### Join all the peers to the channel
#echo "Having all peers join the channel..."
#joinChannel
#
### 更新锚节点
### Set the anchor peers for each org in the channel
#echo "Updating anchor peers for org1..."
#updateAnchorPeers 0 1
#echo "Updating anchor peers for org2..."
#updateAnchorPeers 0 2
#
## 在组织1的peer0节点,安装链码
### Install chaincode on peer0.org1 and peer0.org2
#echo "Installing chaincode on peer0.org1..."
#installChaincode 0 1
#
## 在组织2的peer0节点,安装链码
#echo "Install chaincode on peer0.org2..."
#installChaincode 0 2
#
## 在组织2的peer0节点,初始化链码
## Instantiate chaincode on peer0.org2
#echo "Instantiating chaincode on peer0.org2..."
#instantiateChaincode 0 2
#
### 在组织1的peer0节点,查询链码
## Query chaincode on peer0.org1
#echo "Querying chaincode on peer0.org1..."
#chaincodeQuery 0 1 100
#
## 调用peer0.org1 peer0.org2链码的逻辑,转账
## Invoke chaincode on peer0.org1 and peer0.org2
#echo "Sending invoke transaction on peer0.org1 peer0.org2..."
#chaincodeInvoke 0 1 0 2
#
## 在组织2的peer1节点,安装链码
### Install chaincode on peer1.org2
#echo "Installing chaincode on peer1.org2..."
#installChaincode 1 2
#
### 在组织2的peer1节点,查询链码
## Query on chaincode on peer1.org2, check if the result is 90
#echo "Querying chaincode on peer1.org2..."
#chaincodeQuery 1 2 90

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
