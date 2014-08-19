# -*- mode: ruby -*-
# vi: set ft=ruby :



Vagrant.configure("2") do |config|
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/trusty64"
  end
  config.vm.define "centos" do |centos|
    centos.vm.box = "centos64"
    centos.vm.network "private_network", :ip => "192.168.242.200"
    centos.vm.provision :shell do |shell|
      shell.inline = 'bash -x /vagrant/gemcache_build.sh -n fpm -r https://github.com/michaeltchapman/fpm; ' +
                     'gem install --no-ri --no-rdoc --local --force gemcache/fpm/*; ' +
                     'bash -x /vagrant/ruby_build.sh; ' +
                     'bash -x /vagrant/kibana_build.sh; ' +
                     'mkdir -p /vagrant/rpms; cp *.rpm /vagrant/rpms; '
    end
  end
end
