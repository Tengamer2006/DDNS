Vagrant.configure("2") do |config|
  config.vm.box = "jcpetro97/debian13"

  # Servidor DNS (Bind9)
  config.vm.define "ddns1" do |ddns1|
    ddns1.vm.hostname = "ddns1"
    ddns1.vm.network "private_network",
      ip: "192.168.60.10",
      virtualbox__intnet: "DDNS"
    ddns1.vm.provision "shell", path: "scripts/dns.sh"
  end

  # Servidor DHCP+DDNS (Kea)
  config.vm.define "ddns2" do |ddns2|
    ddns2.vm.hostname = "ddns2"
    ddns2.vm.network "private_network",
      ip: "192.168.60.20",
      virtualbox__intnet: "DDNS"
    ddns2.vm.provision "shell", path: "scripts/dhcp.sh"
  end
end