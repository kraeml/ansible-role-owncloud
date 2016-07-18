require 'spec_helper'

describe 'User testing' do
  %w( root vagrant ).each do |user|
    describe user(user) do
      it { should exist }
    end
  end
end

describe 'Default Packages' do
  %w( ruby2.3 ruby2.3-dev git vim htop ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

path='/home/vagrant/.gem/ruby/2.3.0/bin/'
describe 'Serverspec Files' do
  %w( kitchen rake serverspec-init serverspec-runner ).each do |pkg|
    describe file(path+pkg) do
      it { should be_file }
      it { should be_executable }
      it { should be_owned_by 'vagrant' }
      it { should be_grouped_into 'vagrant' }
    end
  end
end
