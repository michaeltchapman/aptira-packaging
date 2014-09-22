#!/usr/bin/env bash

network=eth1
domain='domain.name'
desired_ruby=2.0.0
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

hash ruby 2>/dev/null || {
      puppet_version=0
}

if [ "${puppet_version}" != '0' ] ; then
  ruby_version=$(ruby --version | cut -d ' ' -f 2)
fi

if [ "${ruby_version}" != "${desired_ruby}" ] ; then
  echo '[elruby-replace-200]' > /etc/yum.repos.d/elruby.repo
  echo "name=\"Elruby ruby replacement 2.0.0\"" >> /etc/yum.repos.d/elruby.repo
  echo "baseurl=\"http://elruby.websages.com/replacement/2.0.0/\$releasever/\$basearch/\"" >> /etc/yum.repos.d/elruby.repo
  echo 'enabled=1' >> /etc/yum.repos.d/elruby.repo
  echo 'gpgcheck=0' >> /etc/yum.repos.d/elruby.repo
 
  yum remove -y ruby ruby-libs ruby-devel
  yum install -y ruby ruby-devel
fi

