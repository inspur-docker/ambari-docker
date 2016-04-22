# Readme


 more detail -> [chinese readme]

# Build Image

Ambari Server:

    $ docker build  --rm -t jiadx/ambari-server .
Ambari agent:

    $ docker build  --rm -t jiadx/ambari-agent -f agent/Dockerfile .

# Pull Image

    $ docker pull jiadx/ambari-server
    $ docker pull jiadx/ambari-agent

# Start
start with docker-compose:

compose file:

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

start :

    $ cd compose
    $ docker-compose up -d


 [chinese readme]: /readme_cn.md