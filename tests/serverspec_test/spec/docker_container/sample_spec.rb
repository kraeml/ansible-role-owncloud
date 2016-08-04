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

packages = owncloud_ubuntu_packages + owncloud_base_packages

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

php_libsmbclients = %w(
  /etc/php/7.0/cli/conf.d/*
  /etc/php/7.0/apache2/conf.d/*
)

document_root = "/var/www/owncloud"
site_ssl = "default-ssl.conf"
site = "000-default.conf"

owc_folders = %w(
  /mnt/data/files
  /mnt/data/config
  /mnt/data
)

pem_file = "/etc/ssl/certs/ssl-cert.pem"
key_file = "/etc/ssl/private/ssl-cert.key"

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

  describe 'smbclient extension should enabled' do
    php_libsmbclients.each do |php_libsmbclient|
      describe command('grep -E ^extension=smbclient.so '+php_libsmbclient ) do
        its(:exit_status) { should eq 0 }
      end
    end
  end

  describe 'user www-data should exist' do
    describe user('www-data') do
      it { should exist }
      it { should have_login_shell '/bin/bash' }
    end
  end

  # May a test for acces recursive
  describe 'folders for owncloud files and config should exist' do
    owc_folders.each do |folder|
      describe file(folder) do
        it { should be_directory }
        it { should be_owned_by 'www-data' }
        it { should be_writable.by('owner') }
        it { should be_readable.by('owner') }
        it { should be_executable.by('owner') }
      end
    end
  end

  describe 'owc source folder should be exist' do
    describe file(document_root) do
      it { should be_directory }
    end
  end

  describe file(pem_file) do
    it { should be_file }
  end

  describe file(key_file) do
    it { should be_file }
  end

  describe 'DocumentRoot on ssl' do
    describe file('/etc/apache2/sites-enabled/'+site_ssl) do
      its(:content) { should match /DocumentRoot\s+\/var\/www\/owncloud/ }
      its(:content) { should match /<IfModule mod_headers.c>\n\s+Header\s+always\s+set\s+Strict-Transport-Security\s+\"max-age=15768000;\s+includeSubDomains;\s+preload\"\n\s+<\/IfModule>/ }
      its(:content) { should match pem_file }
      its(:content) { should match key_file }
    end
  end

  describe 'DocumentRoot without ssl' do
    describe file('/etc/apache2/sites-enabled/'+site) do
      its(:content) { should match /DocumentRoot\s+\/var\/www\/owncloud/ }
    end
  end

  describe 'HOME should set to /var/www' do
    describe file('/etc/apache2/envvars') do
      its(:content) { should match /^unset\s+HOME\nexport\s+HOME=\/var\/www/ }
    end
  end



  after(:all) do
    set :backend, :exec
  end
end
