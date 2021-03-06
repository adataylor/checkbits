#!/bin/sh -x
if id | grep -qv uid=0; then
    echo "Must run setup as root"
    exit 1
fi

create_socket_dir() {
    local dirname="$1"
    local ownergroup="$2"
    local perms="$3"

    mkdir -p $dirname
    chown $ownergroup $dirname
    chmod $perms $dirname
}

set_perms() {
    local ownergroup="$1"
    local perms="$2"
    local pn="$3"

    chown $ownergroup $pn
    chmod $perms $pn
}

rm -rf /jail
mkdir -p /jail
cp -p index.html /jail

./chroot-copy.sh zookd /jail
./chroot-copy.sh zookfs /jail

#./chroot-copy.sh /bin/bash /jail

./chroot-copy.sh /usr/bin/env /jail
./chroot-copy.sh /usr/bin/python /jail

# to bring in the crypto libraries
./chroot-copy.sh /usr/bin/openssl /jail

mkdir -p /jail/usr/lib /jail/usr/lib/i386-linux-gnu /jail/lib /jail/lib/i386-linux-gnu
cp -r /usr/lib/python2.7 /jail/usr/lib

cp /usr/lib/i386-linux-gnu/libssl.so /jail/usr/lib/i386-linux-gnu 
cp /lib/i386-linux-gnu/libssl.so.1.0.0 /jail/lib/i386-linux-gnu 
cp /lib/i386-linux-gnu/libssl.so.1.0.0 /jail/usr/lib/i386-linux-gnu 
cp /usr/lib/i386-linux-gnu/libsqlite3.so.0 /jail/usr/lib/i386-linux-gnu
cp /usr/lib/i386-linux-gnu/libffi.so.6 /jail/usr/lib/i386-linux-gnu
cp /lib/i386-linux-gnu/libnss_dns.so.2 /jail/lib/i386-linux-gnu
cp /lib/i386-linux-gnu/libresolv.so.2 /jail/lib/i386-linux-gnu
cp -r /lib/resolvconf /jail/lib

mkdir -p /jail/usr/local/lib
cp -r /usr/local/lib/python2.7 /jail/usr/local/lib

mkdir -p /jail/etc
cp /etc/localtime /jail/etc/
cp /etc/timezone /jail/etc/
cp /etc/resolv.conf /jail/etc/

mkdir -p /jail/usr/share/zoneinfo
cp -r /usr/share/zoneinfo/America /jail/usr/share/zoneinfo/

mkdir -p /jail/home/httpd/.bitcoin
cp /home/httpd/.bitcoin/bitcoin.conf /jail/home/httpd/.bitcoin

create_socket_dir /jail/authsvc 60011:60011 755
# create_socket_dir /jail/banksvc 60012:60012 755  
create_socket_dir /jail/banksvc 0:0 755  
create_socket_dir /jail/depositsvc 60017:60017 755

mkdir -p /jail/tmp
chmod a+rwxt /jail/tmp

mkdir -p /jail/dev
mknod /jail/dev/urandom c 1 9

cp -r zoobar /jail/
rm -rf /jail/zoobar/db

python /jail/zoobar/zoodb.py init-person
python /jail/zoobar/zoodb.py init-cred
python /jail/zoobar/zoodb.py init-bank

set_perms 61234:61112 700 /jail/zoobar/index.cgi
 
set_perms 61234:61234 755 /jail/
set_perms 61234:61010 755 /jail/zoobar/

set_perms 61234:61000 777 /jail/zoobar/db/
set_perms 61234:61111 777 /jail/zoobar/db/person/
set_perms 61234:61111 777 /jail/zoobar/db/person/person.db

set_perms 60011:60011 700 /jail/zoobar/db/cred/
set_perms 60011:60011 700 /jail/zoobar/db/cred/cred.db

set_perms 60012:60012 700 /jail/zoobar/db/bank/
set_perms 60012:60012 700 /jail/zoobar/db/bank/bank.db
