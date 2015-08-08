FROM        microbox/scratch

ADD         etcd-v0.4.6-linux-amd64/etcd        /bin/etcd

# exclude the cli tool to reduce the size of the image
#ADD         etcd-v0.4.6-linux-amd64/etcdctl     /bin/etcdctl

VOLUME ["/data"]

EXPOSE 4001 7001

ENTRYPOINT ["/bin/etcd"]

CMD ["-data-dir=/data"]
