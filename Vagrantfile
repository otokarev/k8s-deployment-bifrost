Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 4
  end

  config.vm.provision "ansible" do |p|
    p.playbook = "playbook.yml"
    p.verbose        = true
  end

end
