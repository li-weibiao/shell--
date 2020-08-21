#!/bin/bash
#2020年8月21日 14:46:10
#auto config ${FTP_DAEMON} user
#by author li
##################
FTP_YUM="yum -y install"
FTP_DIR="/etc/${FTP_DAEMON}/"
FTP_DB="${FTP_DAEMON}_login"
FTP_VIR="jfedu001"
FTP_DAEMON="vsftpd"
FTP_USR="ftpuser"
FTP_USR_CNF="${FTP_DAEMON}_user_conf"
$FTP_YUM ${FTP_DAEMON}*
rpm -qa | grep ${FTP_DAEMON}
systemctl restart ${FTP_DAEMON}.service
$FTP_YUM pam* libdb-utils libdb* --skip-broken 
touch $FTP_DIR/${FTP_USR}s.txt
echo "$FTP_VIR
123456" > $FTP_DIR/${FTP_USR}s.txt
db_load -T -t hash -f $FTP_DIR/${FTP_USR}s.txt $FTP_DIR/${FTP_DB}.db
chmod 700 $FTP_DIR/${FTP_DB}.db
echo "auth  required  pam_userdb.so  db=$FTP_DIR/${FTP_DB}
account  required  pam_userdb.so  db=$FTP_DIR/${FTP_DB}">/etc/pam.d/${FTP_DAEMON}
useradd -s /sbin/nologin ${FTP_USR}
echo "
#config virtual user FTP
pam_service_name=${FTP_DAEMON}
guest_enable=YES
guest_username=${FTP_USR}
user_config_dir=$FTP_DIR/${FTP_USR_CNF}
virtual_use_local_privs=YES
">>$FTP_DIR/${FTP_DAEMON}.conf
mkdir -p $FTP_DIR/${FTP_USR_CNF}/
touch $FTP_DIR/${FTP_USR_CNF}/$FTP_VIR
echo "
local_root=/home/${FTP_USR}/jfde001
write_enable=YES
anon_world_readable_only=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
">$FTP_DIR/${FTP_USR_CNF}/$FTP_VIR

mkdir -p /home/${FTP_USR}/$FTP_VIR
chown -R ${FTP_USR}:${FTP_USR} /home/${FTP_USR}
systemctl restart ${FTP_DAEMON}.service
systemctl stop firewalld.service
setenforce 0
