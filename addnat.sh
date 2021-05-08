#!/usr/bin/env bash
socatip=172.31.88.186
for ((d=1; d<=32; d++)); do
	if (("$d" < 10)); then
		ssh_port="6100"${d}
		user_port_pre="100"${d}"0"
		echo ${user_port_pre}
	elif (("$d" < 100)); then
		ssh_port="610"${d}
		user_port_pre="10"${d}
		echo ${user_port_pre}
	fi
	#ssh
	nohup socat TCP4-LISTEN:${ssh_port},reuseaddr,fork TCP4:${socatip}:${ssh_port} >> /root/socat.log 2>&1 &
        sed -i '/exit/d' /etc/rc.d/rc.local
        echo "nohup socat TCP4-LISTEN:${ssh_port},reuseaddr,fork TCP4:${socatip}:${ssh_port} >> /root/socat.log 2>&1 &
        " >> /etc/rc.d/rc.local
	#ports
	for ((t=0; t<=9; t++)); do
		port_tmp=${user_port_pre}${t}
		nohup socat TCP4-LISTEN:${port_tmp},reuseaddr,fork TCP4:${socatip}:${port_tmp} >> /root/socat.log 2>&1 &
    		nohup socat -T 600 UDP4-LISTEN:${port_tmp},reuseaddr,fork UDP4:${socatip}:${port_tmp} >> /root/socat.log 2>&1 &
        	sed -i '/exit/d' /etc/rc.d/rc.local
        	echo "nohup socat TCP4-LISTEN:${port_tmp},reuseaddr,fork TCP4:${socatip}:${port_tmp} >> /root/socat.log 2>&1 &
        	nohup socat -T 600 UDP4-LISTEN:${port_tmp},reuseaddr,fork UDP4:${socatip}:${port_tmp}  >> /root/socat.log 2>&1 &
        	" >> /etc/rc.d/rc.local
	done
done

