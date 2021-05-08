#!/usr/bin/env bash
iptables -t nat -F
localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -Ev '(^127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.1[6-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.2[0-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.3[0-1]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$)')
if [ "${localIP}" = "" ]; then
        localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1|head -n 1 )
fi
remote=172.31.88.222
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to ${remote}
for ((d=1; d<=32; d++)); do
	if (("$d" < 10)); then
		ssh_port="6100"${d}
		user_port_first="100"${d}"0"
		user_port_last="100"${d}"9"
		echo ${user_port_last}
	fi
	#ssh
	iptables -t nat -A PREROUTING -p tcp --dport ${ssh_port} -j DNAT --to-destination $remote:${ssh_port}
	iptables -t nat -A POSTROUTING -p tcp -d $remote --dport ${ssh_port} -j SNAT --to-source $localIP
	#ports
	iptables -t nat -A PREROUTING -p tcp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination $remote
	iptables -t nat -A PREROUTING -p udp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination $remote
	iptables -t nat -A POSTROUTING -p tcp -d $remote --dport ${user_port_first}:${user_port_last} -j SNAT --to-source $localIP
	iptables -t nat -A POSTROUTING -p udp -d $remote --dport ${user_port_first}:${user_port_last} -j SNAT --to-source $localIP
done
iptables -t nat -A PREROUTING -p tcp --dport 22222 -j DNAT --to-destination $remote:22
iptables -t nat -A POSTROUTING -p tcp -d $remote --dport 22222 -j SNAT --to-source $localIP
iptables-save > /etc/iptables/rules.v4
