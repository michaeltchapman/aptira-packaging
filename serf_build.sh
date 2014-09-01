# Serf package built from upstream release

SERF_VERSION=0.6.3

rm -rf serf-$SERF_VERSION
mkdir -p serf-$SERF_VERSION
mkdir -p serf-$SERF_VERSION/usr/bin
mkdir -p serf-$SERF_VERSION/etc/serf/conf.d
mkdir -p serf-$SERF_VERSION/etc/init.d

if [ ! -f serf-$SERF_VERSION.zip ]; then
  wget -O serf-$SERF_VERSION.zip https://dl.bintray.com/mitchellh/serf/${SERF_VERSION}_linux_amd64.zip
fi

unzip serf-$SERF_VERSION.zip -d serf-$SERF_VERSION/usr/bin

pleaserun -p sysv -v lsb-3.1 --user serf --group serf --name serf /usr/bin/serf agent --syslog --config-dir /etc/serf/conf.d &> please.out
for i in `cat please.out`; do 
  PDIR=`echo $i | grep 'destination' | cut -d '"' -f 2 | cut -d '/' -f 1-3`
done

rsync -r $PDIR/* serf-$SERF_VERSION

fpm -t rpm -s dir -C serf-${SERF_VERSION} -p ./serf-${SERF_VERSION} -n serf -a x86_64 --config-files etc/serf/conf.d --rpm-user serf --rpm-group serf --before-install pre.sh -f -v ${SERF_VERSION} usr etc

cp serf-${SERF_VERSION}/*.rpm /vagrant/rpms
