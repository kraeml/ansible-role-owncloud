require 'spec_helper'
require 'serverspec'
require 'docker'

# Taken from https://github.com/owncloud-docker/ubuntu/blob/master/Dockerfile
owncloud_ubuntu_packages = %w(
  apt-utils
  apt-transport-https
  iputils-ping
  wget
  curl
  bzip2
  unzip
  cron
  vim )

# Taken from https://github.com/owncloud-docker/owncloud-base/blob/master/Dockerfile
# Changes: php7.0-mb -> php7.0-mbstring
owncloud_base_packages = %w(
  apache2
  libapache2-mod-php7.0
  php7.0-gd
  php7.0-json
  php7.0-mysql
  php7.0-curl
  php7.0-intl
  php7.0-mcrypt
  php-imagick
  php7.0-zip
  php7.0-xml
  php7.0-mbstring
  php-ldap
  php-apcu
  php-redis
  smbclient
  php-smbclient
  mysql-client
)

# Taken from https://github.com/owncloud-docker/owncloud-base/blob/master/Dockerfile
# apache modules oc needs as documented
enmods = %w(
  rewrite
  headers
  env
  dir
  mime
  ssl
)

ensites = %w(
  default-ssl
)

packages = owncloud_ubuntu_packages + owncloud_base_packages

describe ENV['TARGET_CONTAINER'] do
  before(:all) do
    @container = Docker::Container.get(ENV['TARGET_CONTAINER'])
    set :os, family: :debian
    set :backend, :docker
    set :docker_container, @container.id
  end

  describe 'packages should be installed' do
    packages.each do |base|
      describe package(base) do
        it { should be_installed }
      end
    end
  end

  # No a2enmod -l works maybe only on ubuntu 16.04
  describe command('ls -l /etc/apache2/mods-enabled/') do
    enmods.each do |enmod|
      its(:stdout) { should match enmod }
    end
  end

  # No a2ensite -l works maybe only on ubuntu 16.04
    describe command('ls -l /etc/apache2/sites-enabled/') do
    ensites.each do |ensite|
      its(:stdout) { should match ensite }
    end
  end

  after(:all) do
    set :backend, :exec
  end
end
