require 'spec_helper'
require 'serverspec'
require 'docker'

images=%w( ubuntu:16.04 owncloud/ubuntu:latest)

images.each do |image|
  describe image+" image" do
      before(:all) {
          @image = Docker::Image.all().detect{|i| i.info['RepoTags'] == [image]}
      }

      it "should be availble" do
          expect(@image).to_not be_nil
      end
  end
end
