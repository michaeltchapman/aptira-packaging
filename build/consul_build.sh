# Serf package built from upstream release

VERSION=0.4.0

rm -rf consul-$VERSION
mkdir -p consul-$VERSION
mkdir -p consul-$VERSION/usr/bin
mkdir -p consul-$VERSION/etc/consul/conf.d
mkdir -p consul-$VERSION/etc/init.d
mkdir -p consul-$VERSION/var/lib/consul/data

if [ ! -f consul-$VERSION.zip ]; then
  wget -O consul-$VERSION.zip https://dl.bintray.com/mitchellh/consul/${VERSION}_linux_amd64.zip
fi

unzip consul-$VERSION.zip -d consul-$VERSION/usr/bin

cat > pre.sh<<EOF
/usr/bin/getent group consul > /dev/null || /usr/sbin/groupadd -r consul 
/usr/bin/getent passwd consul > /dev/null || /usr/sbin/useradd -r -g consul -d /dev/null -s /sbin/nologin -c "Consul Daemon User" consul
EOF

pleaserun -p sysv -v lsb-3.1 --other_args true --user consul --group consul --name consul /usr/bin/consul agent -server -config-dir /etc/consul/conf.d -data-dir /var/lib/consul/data &> please.out
for i in `cat please.out`; do 
  PDIR=`echo $i | grep 'destination' | cut -d '"' -f 2 | cut -d '/' -f 1-3`
done

rsync -r $PDIR/* consul-$VERSION

fpm -t rpm -s dir -C consul-${VERSION} -p ./consul-${VERSION} -n consul -a x86_64 --config-files etc/consul/conf.d --rpm-user consul --rpm-group consul --before-install pre.sh -f -v ${VERSION} usr etc var

cp consul-${VERSION}/*.rpm /vagrant/rpms
