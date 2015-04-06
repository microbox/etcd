#!/bin/bash
# example script to start a single node ETCD cluster on localhost

HOSTNAME="$(hostname -s)"
LISTEN_ADDRESS="${LISTEN_ADDRESS:-$(hostname -i)}"

ETCD_CLUSTER_TOKEN="${ETCD_CLUSTER_TOKEN:-cluster-$[${RANDOM%100000}+10000]}"
ETCD_INITIAL_CLUSTER="${ETCD_INITIAL_CLUSTER:-${HOSTNAME:-localhost}=http://${LISTEN_ADDRESS}:7001}"
ETCD_INITIAL_CLUSTER_STATE=${ETCD_INITIAL_CLUSTER_STATE:-existing}

DOCKER_NAME="etcd"

if [ -n "${DATA_DIR}"  ] && [ ! -d ${DATA_DIR} ]
then
  mkdir ${DATA_DIR} || exit 1
fi

start_container() {
docker run -d \
  --name ${DOCKER_NAME:-etcd} \
  -p ${DOCKER_LISTEN_ADDRESS:+$DOCKER_LISTEN_ADDRESS:}7001:7001 \
  -p ${DOCKER_LISTEN_ADDRESS:+$DOCKER_LISTEN_ADDRESS:}4001:4001 \
  ${DATA_DIR:+"-v ${DATA_DIR}:/data"} \
  anapsix/etcd --name "${HOSTNAME:-localhost}" --initial-advertise-peer-urls "http://${LISTEN_ADDRESS}:7001" --listen-peer-urls "http://0.0.0.0:7001" --listen-client-urls "http://0.0.0.0:4001" --advertise-client-urls "http://${LISTEN_ADDRESS}:4001" --initial-cluster "${ETCD_INITIAL_CLUSTER}" --initial-cluster-state "${ETCD_INITIAL_CLUSTER_STATE}" --initial-cluster-token "${ETCD_CLUSTER_TOKEN}" --discovery-fallback "proxy"
}

check_container_status() {
  _container="$1"
  status=$(docker inspect -f '{{ .State.Running }}' ${_container} 2>/dev/null)
  if [ $? != 0 ]
  then
    echo na
    return 1
  fi
  echo $status
  unset _container
}

if [[ $(check_container_status ${DOCKER_NAME:-etcd}) == ?(true|false) ]]
then
  echo "ERROR: Container with name \"${DOCKER_NAME:-etcd}\" exists." >&2
  echo "ERROR: Cannot start another one with the same name, exiting.." >&2
  echo "ERROR: You can FORCE remove it with \"docker rm -f etcd\"." >&2
  exit 1
fi

DOCKER_CID=$(start_container)
echo "WARNING: ETCD container started, tailing the logs.."
echo "WARNING: use [CTRL-C] to exit.. container should continue running.."
docker logs -f $DOCKER_CID

if [[ "$(check_container_status $DOCKER_CID)" == "true" ]]
then
  echo >&2
  echo "WARNING: ETCD container is still running with CID=${DOCKER_CID:0:12}" >&2
else
  echo >&2
  echo "WARNING: ETCD container is not running, CID=${DOCKER_CID:0:12}" >&2
fi
