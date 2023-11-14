Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.network "private_network", ip: "192.168.56.101"
  config.vm.network "forwarded_port", guest: 80, host: 8081 #localhost
  config.vm.network "forwarded_port", guest: 22, host: 2222 #sh
  config.vm.network "forwarded_port", guest: 8080, host: 1234 #alternative port
  config.vm.network "forwarded_port", guest: 8000, host: 1256 #alternative port
  config.vm.network "forwarded_port", guest: 3306, host: 1260 #mysql
  config.vm.hostname = "devopsNuria"
  config.vm.synced_folder ".", "/syncd", disabled: false
  config.vm.disk :disk, size: "50GB", primary: true
  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
     vb.cpus = "2"
     vb.name = "devopsNuria"
  end
 end
