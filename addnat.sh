#!/usr/bin/env bash
iptables -t nat -F
user_ip_head="10.0.1"
for ((d=1; d<=50; d++)); do
	user_ip=${user_ip_head}"."${d}
	if (("$d" < 10)); then
		ssh_port="6100"${d}
		user_port_first="100"${d}"0"
		user_port_last="100"${d}"9"
		echo ${user_port_last}
	elif (("$d" < 100)); then
		ssh_port="610"${d}
		user_port_first="10"${d}"0"
		user_port_last="10"${d}"9"
		echo ${user_port_last}
	fi
	iptables -t nat -A PREROUTING -i vmbr0 -p tcp -m tcp --dport ${ssh_port} -j DNAT --to-destination ${user_ip}:22
	iptables -t nat -A PREROUTING -i vmbr0 -p tcp -m tcp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination ${user_ip}
	iptables -t nat -A PREROUTING -i vmbr0 -p udp -m udp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination ${user_ip}	
done
iptables-save > /etc/iptables/rules.v4
