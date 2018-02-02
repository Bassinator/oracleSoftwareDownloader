# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  class Username
    def to_s
      print "Virtual machine needs you oracle delivery cloud user and password.\n"
      print "Username: "
      STDIN.gets.chomp
    end
  end

  class Password
    def to_s
      begin
      system 'stty -echo'
      print "Password: "
      pass = URI.escape(STDIN.gets.chomp)
      ensure
      system 'stty echo'
      end
      pass
    end
  end

  config.vm.box = "ol74"
  config.vm.hostname = 'helper'
  #config.vm.network :private_network, ip: "192.168.56.102"
  config.vm.synced_folder "~/Downloads", "/vagrant_downloads/"


  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "dlOracleTools.yml"
    ansible.extra_vars = {
      oracleLogin: Username.new,
      oraclePass: Password.new
    }
  end

end
