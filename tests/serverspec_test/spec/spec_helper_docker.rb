require 'serverspec'
require 'docker'

set :backend, :docker

set :docker_container, ENV['TARGET']
