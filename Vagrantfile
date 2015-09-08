Vagrant.configure(2) do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  #config.hostmanager.enabled = true
  #config.hostmanager.manage_host = true
  #config.hostmanager.ignore_private_ip = false
  #config.hostmanager.include_offline = true

  config.vm.hostname = 'catalog'
  config.vm.network :private_network, ip: '192.168.10.52'

  #config.vm.network "forwarded_port", guest: 8983, host: 8983
  #config.vm.network "forwarded_port", guest: 5000, host: 5000  # paster server (development)

  #config.ssh.private_key_path = [ '~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa' ]
  #config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "build.yml"
    ansible.extra_vars = {
      ansible_ssh_user: "vagrant",
      local_ckan: "no",
      local_solr: "no"
    }
    ansible.inventory_path = "inventory"
  end

  #config.vm.provision "shell", path: "scripts/provision/catalog.sh"
  #config.vm.provision "shell", path: "scripts/provision/postgres.sh"
  #config.vm.provision "shell", path: "scripts/provision/solr.sh"

end
