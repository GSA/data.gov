# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Ubuntu
  ########

  # Ubuntu 12.04
  config.vm.define "ubuntu1204" do |node|
    node.vm.box = "ubuntu/precise64"
    
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "setup.yml"
      ansible.sudo = true
    end
  end

  # Ubuntu 14.04
  config.vm.define "ubuntu1404", primary: true do |node|
    node.vm.box = "ubuntu/trusty64"
    
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "setup.yml"
      ansible.sudo = true
    end
  end

  # Ubuntu 16.04
  config.vm.define "ubuntu1604" do |node|
    node.vm.box = "ubuntu/xenial64"

    node.vm.provision "shell",
      inline: "sudo sed -i 's/archive.ubuntu.com/free.nchc.org.tw/g' /etc/apt/sources.list"

    node.vm.provision "shell",
      inline: "sudo apt-get update && sudo apt-get install -y python"
    
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "setup.yml"
      ansible.sudo = true
    end
  end

  # Debian
  ########

  # Debian 7
  config.vm.define "debian7" do |node|
      node.vm.box = "debian/wheezy64"
  
      node.vm.provision "ansible" do |ansible|
          ansible.playbook = "setup.yml"
          ansible.sudo = true
      end
  end

  # Debian 8
  config.vm.define "debian8" do |node|
      node.vm.box = "debian/jessie64"
  
      node.vm.provision "ansible" do |ansible|
          ansible.playbook = "setup.yml"
          ansible.sudo = true
      end
  end

  # Debian 9
  config.vm.define "debian9" do |node|
      node.vm.box = "debian/stretch64"

      node.vm.provision "ansible" do |ansible|
          ansible.playbook = "setup.yml"
          ansible.sudo = true
      end
  end

  # CentOS (EL)
  #############

  # CentOS 6
  config.vm.define "centos6" do |node|
    node.vm.box = "bento/centos-6.7"
  
    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "setup.yml"
      ansible.sudo = true
    end
  end
  
  # CentOS 7
  config.vm.define "centos7" do |node|
      node.vm.box = "bento/centos-7.3"
  
      node.vm.provision "ansible" do |ansible|
          ansible.playbook = "setup.yml"
          ansible.sudo = true
      end
  end
  
end
