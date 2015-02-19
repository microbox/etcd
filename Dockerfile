FROM  scratch

ENV ETCD_RELEASE=2.0.3

ADD etcd-v${ETCD_RELEASE}-linux-amd64/etcd        /bin/etcd
# exclude the cli tool to reduce the size of the image
ADD etcd-v${ETCD_RELEASE}-linux-amd64/etcdctl     /bin/etcdctl

VOLUME ["/data"]

EXPOSE 4001 7001 2379 2380

ENTRYPOINT ["/bin/etcd"]

CMD ["--data-dir=/data"]
