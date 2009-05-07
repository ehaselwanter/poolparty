require 'config/requirements'

begin
  require 'hanna/rdoctask'
rescue Exception => e
  require "rake/rdoctask"
end

require 'config/jeweler' # setup gem configuration

Dir['tasks/**/*.rake'].each { |rake| load rake }

desc "Clean tmp directory"
task :clean_tmp do |t|
  FileUtils.rm_rf("#{File.dirname(__FILE__)}/Manifest.txt") if ::File.exists?("#{File.dirname(__FILE__)}/Manifest.txt") 
  FileUtils.touch("#{File.dirname(__FILE__)}/Manifest.txt")
  %w(logs tmp).each do |dir|
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/#{dir}") if ::File.exists?("#{File.dirname(__FILE__)}/#{dir}")
  end
end

desc "Remove the pkg directory"
task :clean_pkg do |t|
  %w(pkg).each do |dir|
    FileUtils.rm_rf("#{File.dirname(__FILE__)}/#{dir}") if ::File.exists?("#{File.dirname(__FILE__)}/#{dir}")
  end
end

desc "Packge with timestamp"
task :update_timestamp do
  data = open("PostInstall.txt").read
  str = "Updated at #{Time.now.strftime("%H:%M %D")}"
  
  if data.scan(/Updated at/).empty?
    data = data ^ {:updated_at => str}    
  else
    data = data.gsub(/just installed PoolParty\!(.*)$/, "just installed PoolParty! (#{str})")
  end
  ::File.open("PostInstall.txt", "w+") {|f| f << data }
end

namespace :gem do
  task(:build).prerequisites.unshift :gemspec # Prepend the gemspec generation
  
  desc "Build the gem only if the specs pass"
  task :test_then_build => [:spec, :build]
  
  desc "Build and install the gem only if the specs pass"
  task :test_then_install => [:spec, :install]
end

task :release => [:update_timestamp]

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "Readme.txt"
  rd.rdoc_files.include("Readme.txt", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
  # rd.template = "hanaa"
end