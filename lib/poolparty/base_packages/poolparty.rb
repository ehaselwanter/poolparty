module PoolParty
  class Base
    plugin :poolparty_base_packages do
      
      def enable                
        # Build hostsfile
        
        has_package(:name => "erlang")
        has_package(:name => "erlang-dev")
        has_package(:name => "erlang-src")
        # has_package(:name => "yaws")
        
        has_package(:name => "rubygems") do
          # These should be installed automagically by poolparty, but just in case
          # TODO: Fix the requires method with a helper
          has_gempackage(:name => "flexmock", :download_url => "http://rubyforge.org/frs/download.php/42580/flexmock-0.8.3.gem")
          has_gempackage(:name => "lockfile", :download_url => "http://rubyforge.org/frs/download.php/18698/lockfile-1.4.3.gem")
          has_gempackage(:name => "logging", :download_url => "http://rubyforge.org/frs/download.php/44731/logging-0.9.4.gem", :requires => [get_gempackage("flexmock"), get_gempackage("lockfile")])          
          
          has_gempackage(:name => "rubyforge", :download_url => "http://rubyforge.org/frs/download.php/45546/rubyforge-1.0.1.gem")
          has_gempackage(:name => "hoe", :download_url => "http://rubyforge.org/frs/download.php/45685/hoe-1.8.2.gem", :version => "1.8", :requires => get_gempackage("rubyforge"))
          has_gempackage(:name => "ZenTest", :download_url => "http://rubyforge.org/frs/download.php/45581/ZenTest-3.11.0.gem", :requires => [get_gempackage("hoe"), get_gempackage("rubyforge")])
          
          has_gempackage(:name => "rake", :download_url => "http://rubyforge.org/frs/download.php/43954/rake-0.8.3.gem")
          has_gempackage(:name => "xml-simple", :download_url => "http://rubyforge.org/frs/download.php/18366/xml-simple-1.0.11.gem")
          has_gempackage(:name => "amazon-ec2", :download_url => "http://rubyforge.org/frs/download.php/43666/amazon-ec2-0.3.1.gem", :requires => get_gempackage("xml-simple"))
          
          has_gempackage(:name => "sexp_processor", :download_url => "http://rubyforge.org/frs/download.php/45589/sexp_processor-3.0.0.gem")
          
          # Capistrano
          has_gempackage(:name => "net-ssh", :download_url => "http://rubyforge.org/frs/download.php/51288/net-ssh-2.0.10.gem", :version => "2.0.10")
          has_gempackage(:name => "net-sftp", :download_url => "http://rubyforge.org/frs/download.php/37669/net-sftp-2.0.1.gem")
          has_gempackage(:name => "net-scp", :download_url => "http://rubyforge.org/frs/download.php/37664/net-scp-1.0.1.gem")
          has_gempackage(:name => "net-ssh-gateway", :download_url => "http://rubyforge.org/frs/download.php/36389/net-ssh-gateway-1.0.0.gem")
          has_gempackage(:name => "echoe", :download_url => "http://rubyforge.org/frs/download.php/51240/echoe-3.1.gem")
          has_gempackage(:name => "highline", :download_url => "http://rubyforge.org/frs/download.php/46328/highline-1.5.0.gem")
          has_gempackage(:name => "capistrano", :download_url => "http://rubyforge.org/frs/download.php/51294/capistrano-2.5.4.gem", :requires => get_gempackage("highline"))
          
          has_gempackage(:name => "ParseTree", :download_url => "http://rubyforge.org/frs/download.php/45600/ParseTree-3.0.1.gem", :requires => [get_gempackage("sexp_processor"), get_gempackage("ZenTest")])
            
          has_gempackage(:name => "ruby2ruby", :download_url => "http://rubyforge.org/frs/download.php/45587/ruby2ruby-1.2.0.gem", :requires => get_gempackage("ParseTree"))
          
          has_gempackage(:name => "activesupport", :download_url => "http://rubyforge.org/frs/download.php/45627/activesupport-2.1.2.gem")
 
          has_gempackage(:name => "RubyInline", :download_url => "http://rubyforge.org/frs/download.php/45683/RubyInline-3.8.1.gem")
          
          has_gempackage(:name => "poolparty", :download_url => "http://github.com/auser/poolparty/tree/master%2Fpkg%2Fpoolparty.gem?raw=true", :requires => [get_gempackage("ruby2ruby"), get_gempackage("RubyInline"), get_gempackage("ParseTree")])
          
          # , :ifnot => "/bin/ps aux | /bin/grep -q pm_node"
          # has_runit_service("pm_node", "pm_node", File.join(File.dirname(__FILE__), "..", "templates/messenger/node/"))
        end
        
        has_exec(:name => "build_messenger", :command => ". /etc/profile && server-build-messenger")
        has_exec(:name => "start_node", :command => ". /etc/profile && server-start-node")        
        
        # execute_on_node do
        has_remotefile(:name => "/usr/bin/puppetrunner") do
          mode 744
          template File.join(File.dirname(__FILE__), "..", "templates/puppetrunner")
        end
        
        # has_exec(:name => "Puppet runner", :command => "/usr/bin/puppetrunner")
        has_cron(:name => "Run the provisioner", :command => "/usr/bin/puppetrunner", :minute => "*/15")
        has_user(:name => user)
        
        # Custom run puppet to minimize footprint
        # TODO: Update the offsetted times
        has_remotefile(:name => "/usr/bin/puppetrerun") do
          mode 744
          template File.join(File.dirname(__FILE__), "..", "templates/puppetrerun")
        end
        
        has_remotefile(:name => "/usr/bin/puppetcleaner") do
          mode 744
          template File.join(File.dirname(__FILE__), "..", "templates/puppetcleaner")
        end
        
        execute_on_master do
          has_exec(:name => "update_hosts", :command => ". /etc/profile && server-update-hosts -n #{cloud.name}")
          has_exec(:name => "Handle load", :command => ". /etc/profile && cloud-handle-load -n #{cloud.name}")
          has_exec(:name => "Ensure provisioning", :command => ". /etc/profile && server-ensure-provisioning -n #{cloud.name}")            
          has_exec(:name => "start master messenger", :command => ". /etc/profile && server-start-master") #, :ifnot => "/bin/ps aux | /bin/grep -q pm_master"
          has_exec(:name => "start client server", :command => ". /etc/profile && server-start-client") #, :ifnot => "/bin/ps aux | /bin/grep -q client_server"
          has_exec(:name => "Maintain the cloud", :command => ". /etc/profile && cloud-maintain -n #{cloud.name}")          
          has_cron(:name => "ensure puppetmaster is running", :command => ". /etc/profile && puppetmasterd --verbose", :hour => "1")
          
        end        
        # has_host(:name => "puppet", :ip => (self.respond_to?(:master) ? self : parent).master.ip)
      end
      
    end  
  end
end