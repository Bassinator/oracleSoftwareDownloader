#!/bin/sh

#USERNAME=$1
#PASSWORD=$2

setenforce Permissive
sed --in-place s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

rpm --install /vagrant_downloads/cntlm-0.92.3-1.x86_64.rpm
cp -u /vagrant/tmpfile.cntlm.conf /usr/lib/tmpfiles.d/cntlm.conf
systemd-tmpfiles --create --remove

if [[ ! -z "$PASSWORD" ]] && [[ ! -z "$USERNAME" ]]; then
  echo $PASSWORD | cntlm -H -d ads.hel.kko.ch -u $USERNAME | while read line
  do
    if [[ "$line" =~ ^PassNTLMv2.* ]]; then
      grep -q '^PassNTLMv2' /etc/cntlm.conf &&
        sed -i "/^PassNTLMv2/ c\\$line" /etc/cntlm.conf ||
        echo "$line" >> /etc/cntlm.conf;
      echo "$line" > /vagrant/.secrets;
    fi
  done
else
  line=$(cat /vagrant/.secrets)
  grep -q '^PassNTLMv2' /etc/cntlm.conf &&
    sed -i "/^PassNTLMv2/ c\\$line" /etc/cntlm.conf ||
  echo "$line" >> /etc/cntlm.conf;
fi

USERNAME=$(grep -oP --max-count=1 "'.*?'" /vagrant/.secrets | head -1 | cut -c'1,7' --complement)

grep -q '^Header' /etc/cntlm.conf &&
  sed -i "/^Header/ c\Header  User-Agent: Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)" /etc/cntlm.conf ||
  echo "Header  User-Agent: Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)" >> /etc/cntlm.conf;

# add helsana rpm repo to noproxy urls
grep -q '^NoProxy' /etc/cntlm.conf &&
  sed -i "/^NoProxy/ c\NoProxy  localhost, 127.0.0.*, 10.*, 192.168.*, admksp01.hel.kko.ch" /etc/cntlm.conf ||
  echo "NoProxy  localhost, 127.0.0.*, 10.*, 192.168.*, admksp01.hel.kko.ch" >> /etc/cntlm.conf;

grep -q '^Proxy' /etc/cntlm.conf &&
  sed -i "/^Proxy/ c\Proxy		proxy-surf:8080" /etc/cntlm.conf ||
  echo "Proxy		proxy-surf:8080" >> /etc/cntlm.conf;

grep -q '^Password' /etc/cntlm.conf &&
  sed -i "/^Password/ c\#Password  top-secret" /etc/cntlm.conf

grep -q '^Username' /etc/cntlm.conf &&
  sed -i "/^Username/ c\Username  $USERNAME" /etc/cntlm.conf ||
  echo "Username  $USERNAME" >> /etc/cntlm.conf;

grep -q '^Domain' /etc/cntlm.conf &&
  sed -i "/^Domain/ c\Domain  ads.hel.kko.ch" /etc/cntlm.conf ||
  echo "Domain  ads.hel.kko.ch" >> /etc/cntlm.conf;


systemctl restart cntlm.service
grep -q '^proxy=' /etc/yum.conf &&
  sed -i '/^proxy=/ c\proxy=http://localhost:3128' /etc/yum.conf ||
  echo "proxy=http://localhost:3128" >> /etc/yum.conf;

# need to be done with yum behind proxy, because rpm -i xyz is not aware of proxy
yes | yum -y install ansible





#yes | yum install -y hel-rootca
