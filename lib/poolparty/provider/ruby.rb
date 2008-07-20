package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz" # implicit :style => :gnu
  requires :ruby_dependencies
end

package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  apt %w( bison zlib1g-dev libssl-dev libreadline5-dev libncurses5-dev file )
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.2.0'
  source "http://rubyforge.org/frs/download.php/38646/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  
  post :install, "sed -i s/require\ 'rubygems'/require\ 'rubygems'\nrequire\ 'rubygems\/gem_runner'/g", "gem update --system", "gem sources -a http://gems.github.com"
  
  requires :ruby
end

package :required_gems do
  description "Poolparty required gem"
  gem 'auser-poolparty'
  requires :s3
  requires :ec2
  requires :aska
end

package :s3 do
  description "Amazon s3"
  gem 'aws-s3'
end
package :ec2 do
  description "Amazon EC2"
  gem 'amazon-ec2'
end
package :aska do
  description "Aska - Expert System"
  gem 'auser-aska'
end
package :rake do
  description "Rake"
  gem 'rake'
end