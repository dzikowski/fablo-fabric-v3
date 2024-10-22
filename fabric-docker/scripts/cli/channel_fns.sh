#!/usr/bin/env bash

set -eu

createChannelAndJoin() {
  local CHANNEL_NAME=$1

  local CORE_PEER_LOCALMSPID=$2
  local CORE_PEER_ADDRESS=$3
  local CORE_PEER_MSPCONFIGPATH=$(realpath "$4")

  local ORDERER_URL=$5

  local DIR_NAME=step-createChannelAndJoin-$CHANNEL_NAME-$CORE_PEER_ADDRESS

  echo "Creating channel with name: ${CHANNEL_NAME}"
  echo "   Orderer: $ORDERER_URL"
  echo "   CORE_PEER_LOCALMSPID: $CORE_PEER_LOCALMSPID"
  echo "   CORE_PEER_ADDRESS: $CORE_PEER_ADDRESS"
  echo "   CORE_PEER_MSPCONFIGPATH: $CORE_PEER_MSPCONFIGPATH"

  mkdir "$DIR_NAME" && cd "$DIR_NAME"

  cp /var/hyperledger/cli/config/"$CHANNEL_NAME".pb .

  osnadmin channel join --channelID "${CHANNEL_NAME}" --config-block ./"$CHANNEL_NAME".pb -o "${ORDERER_URL}"

  rm -rf "$DIR_NAME"
}

createChannelAndJoinTls() {
  local CHANNEL_NAME=$1

  local CORE_PEER_LOCALMSPID=$2
  local CORE_PEER_ADDRESS=$3
  local CORE_PEER_MSPCONFIGPATH=$(realpath "$4")
  local CORE_PEER_TLS_MSPCONFIGPATH=$(realpath "$5")
  local TLS_CA_CERT_PATH=$(realpath "$6")
  local ORDERER_URL=$7

  local CORE_PEER_TLS_CERT_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/client.crt
  local CORE_PEER_TLS_KEY_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/client.key
  local CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/ca.crt

  local ADMIN_SIGN_CERT=$CORE_PEER_MSPCONFIGPATH/signcerts/Admin@org1.example.com-cert.pem
  local ADMIN_PRIVATE_KEY=$CORE_PEER_MSPCONFIGPATH/keystore/priv-key.pem

  local DIR_NAME=step-createChannelAndJoinTls-$CHANNEL_NAME-$CORE_PEER_ADDRESS

  echo "Creating channel with name (TLS): ${CHANNEL_NAME}"
  echo "   Orderer: $ORDERER_URL"
  echo "   CORE_PEER_LOCALMSPID: $CORE_PEER_LOCALMSPID"
  echo "   CORE_PEER_ADDRESS: $CORE_PEER_ADDRESS"
  echo "   CORE_PEER_MSPCONFIGPATH: $CORE_PEER_MSPCONFIGPATH"
  echo "   TLS_CA_CERT_PATH is: $TLS_CA_CERT_PATH"
  echo "   CORE_PEER_TLS_CERT_FILE: $CORE_PEER_TLS_CERT_FILE"
  echo "   CORE_PEER_TLS_KEY_FILE: $CORE_PEER_TLS_KEY_FILE"
  echo "   CORE_PEER_TLS_ROOTCERT_FILE: $CORE_PEER_TLS_ROOTCERT_FILE"
  echo "   ADMIN_PRIVATE_KEY: $ADMIN_PRIVATE_KEY"

  echo "   ADMIN_SIGN_CERT: $ADMIN_SIGN_CERT"

  mkdir "$DIR_NAME" && cd "$DIR_NAME"

  cp /var/hyperledger/cli/config/"$CHANNEL_NAME".pb .
  set -x
  osnadmin channel join --channelID "${CHANNEL_NAME}" --config-block ./"$CHANNEL_NAME".pb -o "${ORDERER_URL}" # --ca-file "${TLS_CA_CERT_PATH}" --client-cert "${ADMIN_SIGN_CERT}" --client-key "${ADMIN_PRIVATE_KEY}"
  peer channel list
  rm -rf "$DIR_NAME"

  sleep 2
  peer channel list
}

fetchChannelAndJoin() {
  local CHANNEL_NAME=$1

  local CORE_PEER_LOCALMSPID=$2
  local CORE_PEER_ADDRESS=$3
  local CORE_PEER_MSPCONFIGPATH=$(realpath "$4")

  local ORDERER_URL=$5

  local DIR_NAME=step-fetchChannelAndJoin-$CHANNEL_NAME-$CORE_PEER_ADDRESS

  echo "Fetching channel with name: ${CHANNEL_NAME}"
  echo "   Orderer: $ORDERER_URL"
  echo "   CORE_PEER_LOCALMSPID: $CORE_PEER_LOCALMSPID"
  echo "   CORE_PEER_ADDRESS: $CORE_PEER_ADDRESS"
  echo "   CORE_PEER_MSPCONFIGPATH: $CORE_PEER_MSPCONFIGPATH"

  mkdir "$DIR_NAME" && cd "$DIR_NAME"

  peer channel fetch newest -c "${CHANNEL_NAME}" --orderer "${ORDERER_URL}"
  peer channel join -b "${CHANNEL_NAME}"_newest.block

  rm -rf "$DIR_NAME"
}

fetchChannelAndJoinTls() {
  local CHANNEL_NAME=$1

  local CORE_PEER_LOCALMSPID=$2
  local CORE_PEER_ADDRESS=$3
  local CORE_PEER_MSPCONFIGPATH=$(realpath "$4")
  local CORE_PEER_TLS_MSPCONFIGPATH=$(realpath "$5")
  local TLS_CA_CERT_PATH=$(realpath "$6")
  local ORDERER_URL=$7

  local CORE_PEER_TLS_CERT_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/client.crt
  local CORE_PEER_TLS_KEY_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/client.key
  local CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_MSPCONFIGPATH/ca.crt

  local DIR_NAME=step-fetchChannelAndJoinTls-$CHANNEL_NAME-$CORE_PEER_ADDRESS

  echo "Fetching channel with name (TLS): ${CHANNEL_NAME}"
  echo "   Orderer: $ORDERER_URL"
  echo "   CORE_PEER_LOCALMSPID: $CORE_PEER_LOCALMSPID"
  echo "   CORE_PEER_ADDRESS: $CORE_PEER_ADDRESS"
  echo "   CORE_PEER_MSPCONFIGPATH: $CORE_PEER_MSPCONFIGPATH"
  echo "   TLS_CA_CERT_PATH is: $TLS_CA_CERT_PATH"
  echo "   CORE_PEER_TLS_CERT_FILE: $CORE_PEER_TLS_CERT_FILE"
  echo "   CORE_PEER_TLS_KEY_FILE: $CORE_PEER_TLS_KEY_FILE"
  echo "   CORE_PEER_TLS_ROOTCERT_FILE: $CORE_PEER_TLS_ROOTCERT_FILE"

  mkdir "$DIR_NAME" && cd "$DIR_NAME"
  set -x
  peer channel fetch newest -c "${CHANNEL_NAME}" --orderer "${ORDERER_URL}" --tls --cafile "$TLS_CA_CERT_PATH"
  peer channel join -b "${CHANNEL_NAME}"_newest.block --tls --cafile "$TLS_CA_CERT_PATH"

  rm -rf "$DIR_NAME"

  sleep 2
  peer channel list
}
