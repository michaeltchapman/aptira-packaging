#!/bin/bash

# libyaml is needed by ruby and comes from epel
if ! yum repolist | grep epel ; then
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  sudo rpm -Uvh epel-release-6*
  rm epel-release-6*
fi

# Build dependencies
for i in rpm-build gcc-c++ glibc-headers glibc-devel openssl-devel readline libyaml-devel readline-devel zlib zlib-devel; do
  if ! yum info $i | grep -q installed ; then
    sudo yum install -y $i
  fi
done

hash fpm 2>/dev/null || {
  sudo gem install fpm --no-ri --no-rdoc
}

MAJOR='2'
MINOR='0'
TEENY='0'
PATCH='481'

FULLNAME=$MAJOR.$MINOR.$TEENY-p$PATCH
VERSION="${MAJOR}.${MINOR}.${TEENY}p${PATCH}"

if [ ! -d ruby-$FULLNAME ]; then
  curl -so ruby-$FULLNAME.tar.gz  http://cache.ruby-lang.org/pub/ruby/$MAJOR.$MINOR/ruby-$FULLNAME.tar.gz
  tar -zxf ruby-$FULLNAME.tar.gz
  rm -f ruby-$FULLNAME.tar.gz
fi

cd ruby-$FULLNAME

./configure --prefix=/usr
make

mkdir -p /tmp/rubybuild
make install DESTDIR=/tmp/rubybuild

cd ..

fpm -s dir \
    -t rpm \
    -n ruby \
    -v $VERSION \
    -a native \
    -p ruby$VERSION-1.el6.`uname -m`.rpm \
    --provides ruby-irb \
    --provides ruby \
    --provides ruby-rdoc \
    --provides ruby-libs \
    --provides rubygems \
    --replaces ruby-irb \
    --replaces ruby \
    --replaces ruby-rdoc \
    --replaces ruby-libs \
    --replaces rubygems \
    -C /tmp/rubybuild \
    usr/lib usr/bin

fpm -s dir \
    -t rpm \
    -n ruby-devel \
    -v $VERSION \
    -p ruby-devel$VERSION.rpm \
    --provides ruby-devel \
    --replaces ruby-devel \
    -a 'x86_64' \
    -C /tmp/rubybuild \
    usr/include

