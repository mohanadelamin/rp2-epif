vi /etc/ssh/sshd_config 
sudo systemctl restart ssh.service
exit
sudo sysctl net.ipv4.ip_forward=1
exit
iptables -t nat -L -n -v | grep 10.96.0.2
iptables -L |  grep 10.96.0.2
iptables -L -v -n |  grep 10.96.0.2
top
exit
top
exit
top
ps aux
exit
ls
exit
