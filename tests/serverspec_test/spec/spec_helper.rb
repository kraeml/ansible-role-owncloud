require 'serverspec'

set :backend, :exec

set :docker_container, ENV['TARGET']
