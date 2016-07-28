require 'spec_helper'
require 'serverspec'
require 'docker'

images=%w( ubuntu:16.04 owncloud/ubuntu:latest ubuntu-16.04:ansible )

images.each do |image|
  describe docker_image(image) do
    it { should exist }
  end
  describe docker_image image do
    its(:inspection) { should_not include 'Architecture' => 'i386' }
    its(['Architecture']) { should eq 'amd64' }
  end
end
