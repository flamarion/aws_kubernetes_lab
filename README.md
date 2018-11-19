# aws_kubernetes_lab

git clone https://github.com/kubernetes-incubator/kubespray.git

cd kubespray/

sudo pip3 install -r requirements.txt

cp -rfp inventory/sample inventory/mycluster

declare -a IPS=(10.0.2.10 10.0.2.11 10.0.2.12 10.0.2.20 10.0.2.21 10.0.2.22 10.0.2.30 10.0.2.31 10.0.2.32)

CONFIG_FILE=inventory/mycluster/hosts.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}

> inventory/mycluster/hosts.ini

vim inventory/mycluster/hosts.ini

```
[all]
node1    ansible_host=10.0.2.10 ip=10.0.2.10
node2    ansible_host=10.0.2.11 ip=10.0.2.11
node3    ansible_host=10.0.2.12 ip=10.0.2.12
node4    ansible_host=10.0.2.20 ip=10.0.2.20
node5    ansible_host=10.0.2.21 ip=10.0.2.21
node6    ansible_host=10.0.2.22 ip=10.0.2.22
node7    ansible_host=10.0.2.30 ip=10.0.2.30
node8    ansible_host=10.0.2.31 ip=10.0.2.31
node9    ansible_host=10.0.2.32 ip=10.0.2.32


[kube-master]
node1
node2
node3

[etcd]
node4
node5
node6

[kube-node]
node7
node8
node9

[k8s-cluster:children]
kube-node
kube-master

[calico-rr]

[vault]
node1
node2
node3
```

vim inventory/mycluster/group_vars/all/all.yml

cloud_provider: aws

vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

ansible-playbook -i inventory/mycluster/hosts.ini --become --become-user=root cluster.yml
