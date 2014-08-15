#!/bin/bash

hash unzip 2>/dev/null || {
  yum install -y unzip
}

hash gcc 2>/dev/null || {
  yum install -y gcc
}

hash rpmbuild 2>/dev/null || {
  yum install -y rpm-build
}

if ! yum info ruby-devel | grep -q installed ; then 
  yum install -y ruby-devel
fi

hash fpm 2>/dev/null || {
  gem install fpm --no-ri --no-rdoc
}

VERSION=3.1.0
if [ ! -d kibana-${VERSION} ]; then
  curl -so kibana-${VERSION}.zip https://download.elasticsearch.org/kibana/kibana/kibana-${VERSION}.zip
  unzip kibana-${VERSION}.zip > /dev/null
  rm -f kibana-${VERSION}.zip
fi

fpm -s dir \
    -t rpm \
    -n kibana \
    -v $VERSION \
    --prefix '/var/lib/kibana' \
    --iteration '1.el6' \
    --license MIT \
    --category 'Applications/Internet' \
    -a 'noarch' \
    --description 'Kibana is a web interface for Logstash.' \
    --config-files 'config.js' \
    --url 'http://kibana.org' \
    --vendor 'kibana.org' \
    --maintainer "Justin Lambert" \
    -x var/lib/kibana/.git \
    -C kibana-${VERSION} .
