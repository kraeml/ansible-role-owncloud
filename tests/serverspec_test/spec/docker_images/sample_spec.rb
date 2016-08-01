require 'spec_helper'
require 'serverspec'
require 'docker'

describe docker_image ENV['TARGET_IMAGE'] do
    it { should exist }
end
describe docker_image ENV['TARGET_IMAGE'] do
  its(:inspection) { should_not include 'Architecture' => 'i386' }
  its(['Architecture']) { should eq 'amd64' }
end

describe docker_container ENV['TARGET_CONTAINER'] do
  it { should exist }
  it { should be_running }
end
