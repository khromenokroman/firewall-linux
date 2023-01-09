#разрешить форвардинг /etc/sysctl.conf
vim /etc/sysctl.conf
net.ipv4.ip_forward=1 #разкоментировать

sudo reboot

sudo iptables -L -v
sudo iptables -L -v -t nat

#input
sudo iptables -A INPUT -i eno0 -j ACCEPT #локалка разрешить
sudo iptables -A INPUT -i lo -j ACCEPT #кольцо разрешить
sudo iptables -A INPUT -i enx001e101f0000 -m state --state ESTABLISHED,RELATED -j ACCEPT #разрешить естаблишед,рел
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP #плохие дроп
sudo iptables -P INPUT DROP #все запретить

# Включаем NAT
sudo iptables -A POSTROUTING -t nat -s 192.168.100.0/24 -o enx001e101f0000 -j MASQUERADE
sudo iptables -A POSTROUTING -t nat -s 192.168.100.0/24 -o wg-raipo -j MASQUERADE

#форвард
sudo iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT #установленные
sudo iptables -A FORWARD -i eno0 -o enx001e101f0000 -j ACCEPT #интернет
sudo iptables -A FORWARD -i eno0 -o wg-raipo -j ACCEPT #vpn


sudo iptables-save > /etc/iptables.rules #переносим все что наделали в файл
vim /etc/network/interfaces
#Добавить строчку к новому интерфейсу чтобы перед поднятием интерфейса запускался фаервол
	pre-up iptables-restore < /etc/iptables.rules