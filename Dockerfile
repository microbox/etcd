FROM        scratch

ADD         etcd-v0.4.6-linux-amd64/etcd        /etcd
#ADD         etcd-v0.4.6-linux-amd64/etcdctl     /bin/etcdctl

ENTRYPOINT ["/etcd"]