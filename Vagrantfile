# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "centos" do |centos|
    centos.vm.box = 'centos64'
    centos.vm.network "private_network", :ip => "192.168.242.200"
    centos.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end

    # Prepare ruby
    centos.vm.provision :shell do |shell|
      shell.inline = 'bash -x /vagrant/provision/bootstrap.sh'
    end

    # Use puppet to prepare repos etc.
    #config.vm.provision :puppet do |puppet|
    #  puppet.module_path = "modules"
    #  puppet.manifest_file = "site.pp"
    #  puppet.hiera_config_path = "hiera/hiera.yaml"
    #  puppet.working_directory = "/vagrant/hiera/data"
    #end

    # Install build tools
    centos.vm.provision :shell do |shell|
      shell.inline = 'bash -x /vagrant/build/gemcache_build.sh -n fpm -r https://github.com/michaeltchapman/fpm; ' +
                     'gem install --no-ri --no-rdoc --local --force gemcache/fpm/*;' +
                     'bash -x /vagrant/build/gemcache_build.sh -n pleaserun -r https://github.com/michaeltchapman/pleaserun; ' +
                     'gem install --no-ri --no-rdoc --local --force gemcache/pleaserun/*;'
                     #'bash -x /vagrant/ruby_build.sh; ' +
                     #'bash -x /vagrant/kibana_build.sh; ' +
                     #'mkdir -p /vagrant/rpms; cp *.rpm /vagrant/rpms; '
    end
  end
end
