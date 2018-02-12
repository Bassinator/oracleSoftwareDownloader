# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

require 'yaml'

current_dir    = File.dirname(File.expand_path(__FILE__))
configs        = YAML.load_file("#{current_dir}/config.yml")
vars = configs['vars'][configs['vars']['use']]


Vagrant.configure("2") do |config|

  class Username
    def initialize(account)
      @account = account
    end
    def to_s
      print "Virtual machine needs your " + @account + " login and password.\n"
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
  #config.vm.box = "centos/7"
  config.vm.hostname = 'oraDLhelper'
  #config.vm.network :private_network, ip: "192.168.56.102"
  config.vm.synced_folder vars['download_dir'], "/vagrant_downloads/"

  # ask account, if hashed secrets not yet stored on disk
  unless File.exist?('.secrets')
    username=Username.new("Corporate account");
    password=Password.new;
  end

  if (vars['proxy'])
    config.vm.provision "shell" , path: "script.sh", env: {"USERNAME" =>username, "PASSWORD" => password}
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "dlOracleTools.yml"
    ansible.extra_vars = {
      oracleLogin: Username.new("Oracle eDelivery Cloud Account"),
      oraclePass: Password.new
    }
  end

end
