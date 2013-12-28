# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME    = ENV.fetch("BOX_NAME",         "ubuntu")
BOX_URI     = ENV.fetch("BOX_URI",          "http://files.vagrantup.com/precise64.box")

Vagrant::Config.run do |config|
  config.vm.box       = BOX_NAME
  config.vm.box_url   = BOX_URI

  provision_essentials = [
    %{apt-get update -q},
    %{apt-get install -q -y vim},
    %{apt-get install -q -y git-core},
  ]

  provision_guest_additions = [
    %{if [ ! -d /opt/VBoxGuestAdditions-4.3.4/ ]; then},
      %{apt-get install -q -y linux-headers-generic-lts-raring dkms},
      %{wget -cq http://dlc.sun.com.edgesuite.net/virtualbox/4.3.4/VBoxGuestAdditions_4.3.4.iso},
      %{echo "f120793fa35050a8280eacf9c930cf8d9b88795161520f6515c0cc5edda2fe8a  VBoxGuestAdditions_4.3.4.iso" | sha256sum --check || exit 1},
      %{mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.3.4.iso /mnt},
      %{/mnt/VBoxLinuxAdditions.run --nox11},
      %{umount /mnt},
    %{fi},
  ]

  backport_kernel = [
    %[tmp=`mktemp -q` && {],
      %[apt-get install -q -y --no-upgrade linux-image-generic-lts-raring | tee "$tmp"],
      %[NUM_INST_PACKAGES=`awk \'$2 == "upgraded," && $4 == "newly" { print $3 }\' "$tmp"`],
      %[rm "$tmp"],
    %[}],

    %{if [ "$NUM_INST_PACKAGES" -gt 0 ]; then},
      %{echo ""},
      %{echo "******************************************************************"},
      %{echo "Rebooting to activate new kernel."},
      %{echo ""},
      %{echo "Use \'vagrant halt\' followed by \'vagrant up\' to complete the build."},
      %{echo "******************************************************************"},
      %{shutdown -r now},
      %{exit 0},
    %{fi},
  ]

  provision_docker = [
    %{if [[ -z $(type -p docker) ]]; then},
      %{wget -q -O - https://get.docker.io/gpg | apt-key add -},
      %{echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list},
      %{apt-get update -q; apt-get install -q -y --force-yes lxc-docker},
      %{usermod -a -G docker vagrant},
    %{fi},
  ]

  def provision_docker_proxy
    [
      %{echo \"export http_proxy=#{ENV['http_proxy']}\nexport https_proxy=#{ENV['https_proxy']}\" > /etc/default/docker},
      %{service docker restart},
    ]
  end

  provision_dockerize = [
    %{export dockerize_version="master"},
    %{dockerize_source="https://github.com/roovo/dockerize/archive/${dockerize_version}"},
    %{dockerize_dir="/usr/local/src/dockerize-${dockerize_version}"},
    %{dockerize_bin="${dockerize_dir}/bin/dockerize"},
    %{if [[ ! -e $dockerize_bin ]]; then wget -q -O - "${dockerize_source}.tar.gz" | tar -C /usr/local/src -zxv; fi},
    %{if [[ $(sudo grep -c "$dockerize_bin init" /root/.profile)         == 0 ]]; then sudo sudo echo 'eval \"\$(/usr/local/src/dockerize-'\"${dockerize_version}\"'/bin/dockerize init -)\"' >> /root/.profile;         fi},
    %{if [[ $(sudo grep -c "$dockerize_bin init" /home/vagrant/.profile) == 0 ]]; then sudo sudo echo 'eval \"\$(/usr/local/src/dockerize-'\"${dockerize_version}\"'/bin/dockerize init -)\"' >> /home/vagrant/.profile; fi},
  ]

  provisioning_script  = ["export DEBIAN_FRONTEND=noninteractive"]
  provisioning_script += provision_essentials
  provisioning_script += provision_guest_additions
  provisioning_script += backport_kernel
  provisioning_script += provision_docker
  provisioning_script += provision_docker_proxy
  provisioning_script += provision_dockerize
  provisioning_script << %{echo "\nVM ready!\n"}

  config.vm.provision :shell, :inline => provisioning_script.join("\n")
end
