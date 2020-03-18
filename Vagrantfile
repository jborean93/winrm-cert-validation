# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

inventory = YAML.load_file('inventory.yml')

Vagrant.configure("2") do |config|
  config.vm.box = inventory['all']['children']['windows']['hosts'].values[0]['vagrant_box']
  config.vm.hostname = inventory['all']['children']['windows']['hosts'].keys[0]
  config.vm.network :private_network, ip: inventory['all']['children']['windows']['hosts'].values[0]['ansible_host']

  config.vm.provider :libvirt do |lv|
    lv.cpus = 4
    lv.memory = 8192
  end

  config.vm.provision "ansible" do |ansible|
    ansible.inventory_path = "inventory.yml"
    ansible.limit = "all"
    ansible.playbook = "main.yml"
    ansible.verbose = '-vv'
  end
end
