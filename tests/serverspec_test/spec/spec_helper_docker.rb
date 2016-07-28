require 'serverspec'

set :backend, :docker

set :docker_container, ENV['TARGET']
