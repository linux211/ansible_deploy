### 1, 准备playbook和安装包
#### 1.1，拷贝playbook到ansible机器的任意目录
|ansible机器|ip|user|passwd|
|---|---|---|---|
|ansible|xx.xx.xx.xx|xx|xx|

#### 1.2, 拷贝安装包到ansible机器的指定目录
```
第三方目录为/pkg_repo/3rd
服务包目录为/pkg_repo/service
包目录的用户为xx，密码为xx

```

### 2, 配置基础设施
#### 2.1, 在安装组件memcache，twemproxy，zookeeper，kafka，asgard，apigateway的节点创建apigateway用户
```shell

# 关闭rpc服务
service rpcbind stop

# 禁止自启动服务
chkconfig rpcbind off

sed '/apigateway ALL=NOPASSWD:ALL/d' /etc/sudoers
userdel -r apigateway
groupdel apigateway
groupadd apigateway
useradd -g apigateway -d /opt/apigateway apigateway
echo "apigateway:Huawei@123" | chpasswd
mkdir /opt/apigateway
chown -R apigateway:apigateway /opt/apigateway
echo "apigateway ALL=NOPASSWD:ALL" >> /etc/sudoers
```

#### 2.2, 在安装组件gaussdb，silvan，nginx_apigateway，nginx_silvan的节点创建onframework用户
```shell
sed '/onframework ALL=NOPASSWD:ALL/d' /etc/sudoers
userdel -r onframework
groupdel onframework
groupadd onframework
useradd -g onframework -d /opt/onframework onframework
echo "onframework:Onframework@123" | chpasswd
mkdir /opt/onframework
chown -R onframework:onframework /opt/onframework
echo "onframework ALL=NOPASSWD:ALL" >> /etc/sudoers
```

#### 2.3, 配置ansible机器到所有安装节点的免密钥ssh登录
```shell
ssh-keygen -f "/home/admin/.ssh/known_hosts" -R xx.xx.xx.xx
ssh-copy-id -i ~/.ssh/id_rsa.pub apigateway@xx.xx.xx.xx
ssh-copy-id -i ~/.ssh/id_rsa.pub onframework@xx.xx.xx.xx
```

### 3, 服务部署步骤
#### 3.1, 配置服务的节点ip信息，配置group_vars/all文件的变量
|变量|说明|
|---|---|
|iam.ip|iam的ip|
|common.ips|服务所有节点的ip，根据apigateway规模而配置|
|gaussb.ips.primary|gaussdb的主节点，根据gaussdb的主节点实际配置|
|gaussb.ips.standby|gaussdb的备节点，根据gaussdb的备节点实际配置，如果没有注释即可|
|silvan.ips|silvan的所有节点的ip，根据silvan实际配置|
|nginx_silvan.ips.primary|nginx_silvan的主节点，根据nginx_silvan主节点实际配置|
|nginx_silvan.ips.standby|nginx_silvan的备节点，根据nginx_silvan备节点实际配置，如果没有注释即可|
|memcache.ips|memcache的所有节点的ip，根据memcache实际配置|
|twemproxy.ips|twemproxy的所有节点的ip，根据twemproxy实际配置|
|twemproxy.hosts|twemproxy的所有节点的ip和port，根据twemproxy实际配置|
|zookeeper.ips|zookeeper的所有节点的ip，根据zookeeper实际配置|
|zookeeper.hosts|zookeeper的所有节点的ip和port，根据zookeeper实际配置|
|kafka.ips|kafka的所有节点的ip，根据kafka实际配置|
|kafka.hosts|kafka的所有节点的ip和port，根据kafka实际配置|
|asgard.ips|asgard的所有节点的ip，根据asgard实际配置|
|apigateway.ips|apigateway的所有节点的ip，根据apigateway实际配置|
|nginx_apigateway.ips.primary|nginx_apigateway的主节点，根据nginx_apigateway主节点实际配置|
|nginx_apigateway.ips.standby|nginx_apigateway的备节点，根据nginx_apigateway备节点实际配置，如果没有注释即可|

#### 3.2, 配置组件和节点关系拓扑，配置hosts文件的机器组信息
```
根据服务规模而配置，每行代表一个节点，最左边配置的hostname的序号要与common.ips的序号相同
```
|组名|说明|
|---|---|
|common_apigateway|common_apigateway的所有节点集合|
|common_console|common_console的所有节点集合|
|gaussdb|gaussdb的所有节点集合|
|silvan|silvan的所有节点集合|
|nginx_silvan|nginx_silvan的所有节点集合|
|memcache|memcache的所有节点集合|
|twemproxy|twemproxy的所有节点集合|
|zookeeper|zookeeper的所有节点集合|
|kafka|kafka的所有节点集合|
|asgard|asgard的所有节点集合|
|apigateway|apigateway的所有节点集合|
|nginx_apigateway|nginx_apigateway的所有节点集合|

#### 3.3, 在ansible机器上执行部署命令
```
每个组件都可单独部署，根据site.yml中的tag名可以指定部署该组件，在执行命令后加-t选项即可
```
|部署类型|部署命令|
|---|---|
|全部停止|./stop.sh|
|全部卸载|./uninstall.sh|
|全部部署|./install.sh|

#### 3.4, 执行部署脚本完成后删除用户sudo权限
```shell
sed '/apigateway ALL=NOPASSWD:ALL/d' /etc/sudoers
sed '/onframework ALL=NOPASSWD:ALL/d' /etc/sudoers
```