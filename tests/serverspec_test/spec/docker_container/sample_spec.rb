require 'spec_helper_docker'
require 'serverspec'
require 'docker'

describe docker_container 'testcontainer' do
  it { should exist }
  it { should be_running }
end
