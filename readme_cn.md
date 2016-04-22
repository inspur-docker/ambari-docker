# ambari docker

## 说明
 本镜像安装了ambari-server和ambari-agent.

 并安装 [docker-gen]，可以自动检测slave节点容器的主机名称-IP的映射，并增加到/etc/hosts文件。

##  构建镜像
Ambari Server:

    $ docker build  --rm -t jiadx/ambari-server .
Ambari agent:

    $ docker build  --rm -t jiadx/ambari-agent -f agent/Dockerfile .

## 启动多节点 hadoop 容器
1.使用镜像启动一个多节点的hadoop集群，需要ambari agent节点能识别ambari server主机，本例使用
`-link`连接容器，也可以安装DNS服务发现如[docker-dns-gen]。

2.hadoop master节点能自动发现slave节点的`主机名-IP`映射。

### 启动容器做为ambari server:

    $ docker run -d -h ambari-server --name ambari-server \
               -p 8080:8080 \
               jiadx/ambari-server \
               /start-server.sh setup

### 启动容器做为hadoop master节点
   需要通过环境变量`HADOOP_ROLE=master`表明当前容器的角色:

    $ docker run -d -h hadoop-master \
                -link ambari-server:ambari-server \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                -e "HADOOP_ROLE=master" \
                jiadx/ambari-agent \
                /start-agent.sh reset ambari-server`

### 启动容器做为hadoop slave节点
   需要使用标签`hadoop.role=slave`,带有此标签的主机名/IP的映射
会写入到`HADOOP_ROLE=master`容器的`/etc/hosts`文件:

    $ docker run -d -h hadoop-slave1 \
                -link ambari-server:ambari-server \
                -l hadoop.role=slave \
                jiadx/ambari-agent \
                /start-agent.sh reset ambari-server
### 创建hadoop集群
浏览器访问ambari server节点的8080端口，通过UI创建hadoop集群。

## 启动all in one 容器
如需要更多定制化操作-如all-in-one，可以启动shell：

    $ docker run -ti -h ambari-server --name ambari-server  jiadx/ambari-server bash



## 使用docker-compose启动

由于创建的节点较多，可以使用docker-compose.xml文件进行编排，参考如下：


    ambari-server:
        image: jiadx/ambari-server
        ports:
            - "8080:8080"
        command: ["/start-server.sh","setup"]
        hostname: ambari-server
    hadoop-master:
        image: jiadx/ambari-agent
        links:
            - ambari-server:ambari-server
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        command: ["/start-agent.sh","reset","ambari-server"]
        hostname: hadoop-master
        environment:
           HADOOP_ROLE: "master"
    hadoop-slave1:
        image: jiadx/ambari-agent
        links:
            - ambari-server:ambari-server
        command: ["/start-agent.sh","reset","ambari-server"]
        hostname: hadoop-slave1
        labels:
           hadoop.role: "slave"

部署：

    docker-compose up -d
# 创建Hadoop集群
浏览器访问ambari-server容器的8080，根据向导创建hadoop集群。

如果容器环境没有配置dns服务发现，可能会提示hadoop-slave1节点不能解析hadoop-master的名称。
可如下方式解决：

   1.配置dns服务发现，参考 [docker-dns-gen]

  2.slave节点也增加`HADOOP_ROLE: "master"`环境变量

# 注意

  本项目的repo/ambari.repo为内网资源库地址，请根据实际环境修改。

  repo/ambari_origin.repo为官方资源库地址。

  [docker-gen]: https://github.com/jwilder/docker-gen
  [docker-dns-gen]: https://github.com/jiadexin/docker-dns-gen