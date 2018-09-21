# -*- mode: ruby -*-

DOMAIN = "vim-and-vi-mode.local"

instances = [
  {
    :name   => "alpine37",
    :image  => "generic/alpine37"
  },
  {
    :name   => "ubuntu1204",
    :image  => "ubuntu/precise64"
  },
  {
    :name   => "ubuntu1404",
    :image  => "ubuntu/trusty64"
  },
  {
    :name   => "ubuntu1604",
    :image  => "ubuntu/xenial64"
  },
  {
    :name   => "debian7",
    :image  => "debian/wheezy64"
  },
  {
    :name   => "debian8",
    :image  => "debian/jessie64"
  },
  {
    :name   => "debian9",
    :image  => "debian/stretch64"
  },
  {
    :name   => "centos6",
    :image  => "bento/centos-6.9"
  },
  {
    :name   => "centos7",
    :image  => "bento/centos-7.4"
  }
]

# Main
######

Vagrant.configure("2") do |config|

  # Loop by each.
  instances.each do |instance|

    config.vm.define instance[:name] do |node|
      node.vm.box = instance[:image].to_s

      # hostname = <instance name>.<DOMAIN>
      if ( instance[:name].to_s != "alpine37" )
        node.vm.hostname = instance[:name].to_s + "." + DOMAIN
      end

      node.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
      end

      # Provision before run playbook.
      case
      when instance[:name].to_s == "alpine37"
        node.vm.provision "shell",
          inline: "sudo apk update && sudo apk add python"
      when instance[:name].to_s == "ubuntu1604"
        node.vm.provision "shell",
          inline: "sudo sed -i 's/archive.ubuntu.com/free.nchc.org.tw/g' /etc/apt/sources.list"
        node.vm.provision "shell",
          inline: "sudo apt update && sudo apt install -y python"
      end

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "provision.yml"
        ansible.become = true
      end
    end

  end
end

# vi: set ft=ruby :
