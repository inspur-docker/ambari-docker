#!/bin/bash
service sshd start

if [[ $1 == "setup" ]]; then
  ambari-server setup -s -j $JAVA_HOME
fi

ambari-server restart &

#start docker-gen in master node
HADOOP_ROLE=${HADOOP_ROLE:-slave}
if [ "$HADOOP_ROLE" = "master" ]; then
  docker-gen -watch -notify "/add-hosts.sh /etc/hosts.new" /etc/etc-hosts.tmpl /etc/hosts.new &
fi

while [ 1 ]
do
    tail -f /var/log/ambari-server/ambari-server.log
	sleep 10
done