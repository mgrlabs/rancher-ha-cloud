

# References

- https://docs.docker.com/engine/install/ubuntu/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
- https://itnext.io/docker-in-docker-521958d34efd
- https://letsencrypt.org/about/
- https://cert-manager.io/docs/installation/kubernetes/
- https://spr.com/how-to-create-a-namespace-in-helm-3/


# Design Notes

The worker role should not be used or added on nodes with the etcd or controlplane role:
- https://rancher.com/docs/rancher/v2.x/en/cluster-provisioning/production/

RKE can use a bastion host:
- https://rancher.com/docs/rke/latest/en/config-options/bastion-host/

Access Kubernetes API behind a bastion host:
- https://stevesloka.com/access-kubernetes-master-behind-bastion-box/
