Vagrant.configure("2") do |config|
  config.vm.box = "jcpetro97/debian13"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "512"
  end

  # --- Servidor DNS ---
  config.vm.define "dns" do |dns|
    dns.vm.hostname = "ns1"
    dns.vm.network "private_network", ip: "192.168.60.3", virtualbox__intnet: "DDNS"
    dns.vm.provision "shell", path: "provision_dns.sh"
  end

  # --- Servidor DHCP ---
  config.vm.define "dhcp" do |dhc|
    dhc.vm.hostname = "dhcp"
    dhc.vm.network "private_network", ip: "192.168.60.2", virtualbox__intnet: "DDNS"
    dhc.vm.provision "shell", path: "provision_dhcp.sh"
  end

  # --- Cliente ---
  config.vm.define "cliente" do |cli|
    cli.vm.hostname = "cliente-vag"
    cli.vm.network "private_network", type: "dhcp", virtualbox__intnet: "DDNS"
    cli.vm.provision "shell", path: "provision_client.sh"
  end
end