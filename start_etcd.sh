#!/bin/bash
# example script to start a single node ETCD cluster on localhost

NAME="$(hostname -s)"
IPADDRESS="$(hostname -i)"

ETCD_CLUSTER_TOKEN="${ETCD_CLUSTER_TOKEN:-cluster-$[${RANDOM%100000}+10000]}"
ETCD_INITIAL_CLUSTER="${NAME:-localhost}=http://${IPADDRESS}:7001"


if [ -n "${DATA_DIR}"  ] && [ ! -d ${DATA_DIR} ]
then
  mkdir ${DATA_DIR} || exit 1
fi

docker run -it \
  --name etcd \
  -p ${DOCKER_IPADDRESS:+$DOCKER_IPADDRESS:}7001:7001 \
  -p ${DOCKER_IPADDRESS:+$DOCKER_IPADDRESS:}4001:4001 \
  ${DATA_DIR:+"-v ${DATA_DIR}:/data"} \
  anapsix/etcd --name "${NAME:-localhost}" --initial-advertise-peer-urls "http://${IPADDRESS}:7001" --listen-peer-urls "http://0.0.0.0:7001" --listen-client-urls "http://0.0.0.0:4001" --advertise-client-urls "http://${IPADDRESS}:4001" --initial-cluster "${ETCD_INITIAL_CLUSTER}" --initial-cluster-state "new" --initial-cluster-token "${ETCD_CLUSTER_TOKEN}" --discovery-fallback "proxy"

