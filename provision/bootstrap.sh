#!/usr/bin/env bash

network=eth1
domain='domain.name'
desired_ruby=2.0.0
desired_puppet=3.7.2
mirror='http://centos.mirror.uber.com.au'
proxy="${proxy:-}"

while getopts "h?p:" opt; do
    case "$opt" in
    h|\?)
        echo "Not helpful help message"
        exit 0
        ;;
    p)  proxy=$OPTARG
        ;;
    esac
done

# Set either yum or apt to use an http proxy.
if [ $proxy ] ; then
    echo 'setting proxy'
    export http_proxy=$proxy

    if [ -f /etc/redhat-release ] ; then
        if [ ! $(cat /etc/yum.conf | grep '^proxy=') ] ; then
            echo "proxy=$proxy" >> /etc/yum.conf
        fi
    elif [ -f /etc/debian_version ] ; then
        if [ ! -f /etc/apt/apt.conf.d/01apt-cacher-ng-proxy ] ; then
            echo "Acquire::http { Proxy \"$proxy\"; };" > /etc/apt/apt.conf.d/01apt-cacher-ng-proxy;
            apt-get update -q
        fi
    else
        echo "OS not detected! Weirdness inbound!"
    fi
else
    echo 'not setting proxy'
fi

if ! grep -q $mirror /etc/yum.repos.d/* ; then
  # Kill everything and start clean
  rm -rf /etc/yum.repos.d/*

  cat > /etc/yum.repos.d/CentOS-Base.repo<<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=${mirror}/\$releasever/os/\$basearch/
enabled=1
gpgcheck=1
EOF

  cat > /etc/yum.repos.d/CentOS-Updates.repo<<EOF
[updates]
name=CentOS-\$releasever - Updates
baseurl=${mirror}/\$releasever/updates/\$basearch/
enabled=1
gpgcheck=1
EOF

  cat > /etc/yum.repos.d/CentOS-Extras.repo<<EOF
[extras]
name=CentOS-\$releasever - Base
baseurl=${mirror}/\$releasever/extras/\$basearch/
enabled=1
gpgcheck=1
EOF

fi

if [ ! -f /root/.gemrc ]; then
  echo 'gem: --bindir /usr/bin' > /root/.gemrc
fi

hash ruby 2>/dev/null || {
      puppet_version=0
}

if [ "${puppet_version}" != '0' ] ; then
  ruby_version=$(ruby --version | cut -d ' ' -f 2)
fi

if [ "${ruby_version}" != "${desired_ruby}" ] ; then
  echo '[elruby-replace-200]' > /etc/yum.repos.d/elruby.repo
  echo "name=\"Elruby ruby replacement 2.0.0\"" >> /etc/yum.repos.d/elruby.repo
  echo "baseurl=\"http://stacktira.aptira.com/repo/elruby/\"" >> /etc/yum.repos.d/elruby.repo
  echo 'enabled=1' >> /etc/yum.repos.d/elruby.repo
  echo 'gpgcheck=0' >> /etc/yum.repos.d/elruby.repo

  yum remove -y ruby ruby-libs ruby-devel
  yum install -y ruby ruby-devel
fi

# Ruby-augeas is needed for puppet, but is handled separately
# since it requires native extensions to be compiled
if ! gem list | grep ruby-augeas ; then
    # comes from updates repo
    yum install gcc augeas-devel -y -q
    gem install ruby-augeas --no-ri --no-rdoc
    yum remove -y -q gcc cpp
fi

# Install puppet from gem. This is not best practice, but avoids
# repackaging large numbers of rpms and debs for ruby 2.0.0
hash puppet 2>/dev/null || {
  puppet_version=0
}

if [ "${puppet_version}" != '0' ] ; then
    puppet_version=$(puppet --version)
fi

if [ "${puppet_version}" != "${desired_puppet}" ] ; then
    gem install puppet --no-ri --no-rdoc
fi

# Ensure puppet user and group are configured
if ! grep puppet /etc/group; then
    echo 'adding puppet group'
    groupadd puppet
fi
if ! grep puppet /etc/passwd; then
    echo 'adding puppet user'
    useradd puppet -g puppet -d /var/lib/puppet -s /sbin/nologin
fi

# Set up minimal puppet directory structure
if [ ! -d /etc/puppet ]; then
    echo 'creating /etc/puppet'
    mkdir /etc/puppet
fi

if [ ! -d /etc/puppet/manifests ]; then
    echo 'creating /etc/puppet/manifests'
    mkdir /etc/puppet/manifests
fi

if [ ! -d /etc/puppet/modules ]; then
    echo 'creating /etc/puppet/modules'
    mkdir /etc/puppet/modules
fi

rm -f /root/.gemrc
