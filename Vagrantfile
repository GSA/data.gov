Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"

  # Customize hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.hostname = 'catalog.dev'
  config.vm.network :private_network, ip: '192.168.10.82'

  # Customize vm provider
  config.vm.provider :virtualbox do |vb|
    vb.memory = "4096"
  end

  # Provision vm through ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/catalog.yml"
    ansible.limit = "catalog.dev"
    ansible.sudo = true
    ansible.extra_vars = {
      ansible_ssh_user: "vagrant",
      local_ckan: "no",
      local_solr: "no"
    }
    ansible.inventory_path = "ansible/hosts"
  end

  # Configure synced_folders
=begin
  config.vm.synced_folder "synced_folders/src", "/usr/lib/ckan/src",
                          id: "ckan_src",
                          owner: "root",
                          group: "root",
                          #mount_options: ["dmode=775","fmode=664"],
                          create: true

  config.vm.synced_folder "synced_folders/config", "/etc/ckan/",
                          id: "ckan_config",
                          owner: "root",
                          group: "root",
                          #mount_options: ["dmode=775","fmode=664"],
                          create: true
=end
end
