require 'serverspec'
require 'docker'

set :backend, :exec

set :docker_container, ENV['TARGET_CONTAINER']
set :docker_image, ENV['TARGET_IMAGE']
