=begin rdoc
  Application
  This handles user interaction
=end
module PoolParty
  extend self
  
  class Application        
    class << self
            
      def options(opts={})
        load_options!
        @options ||= OpenStruct.new(default_options.merge(opts))
      end

      # Load options 
      def load_options!
        require 'choice'
        Choice.options do |op|
          header ''
          header 'Required options'
          option :access_key_id do
            short '-A'
            long '-access-key=key'
            desc "EC2 access key (default ENV['ACCESS_KEY])"
            default ENV['ACCESS_KEY']
          end
          # op.on('-A key', '--access-key key', "Ec2 access key (ENV['ACCESS_KEY'])") { |key| default_options[:access_key_id] = key }
          # op.on('-S key', '--secret-access-key key', "Ec2 secret access key (ENV['SECRET_ACCESS_KEY'])") { |key| default_options[:secret_access_key] = key }
          # op.on('-I ami', '--image-id id', "AMI instance (required)") {|id| default_options[:ami] = id }
          # op.on('-p port', '--host_port port', "Run on specific host_port (default: 7788)") { |host_port| default_options[:host_port] = host_port }
          # op.on('-o port', '--client_port port', "Run on specific client_port (default: 7788)") { |client_port| default_options[:client_port] = client_port }
          # op.on('-e env', '--environment env', "Run on the specific environment (default: development)") { |env| default_options[:env] = env }
          # op.on('-s', '--[no-]sessions', "Run with sessions (default: false)") { |sessions| default_options[:sessions] = sessions }
          # op.on('-d user-data','--user-data data', "Extra data to send each of the instances (default: "")") { |data| default_options[:user_data] = data }
          # op.on('-t seconds', '--polling-time', "Time between polling in seconds (default 50)") {|t| default_options[:polling_time] = t }
          # op.on('-v', '--[no-]verbose', 'Run verbosely (default: false)') {|v| default_options[:debug] = v}
          # op.on('-i number', '--minimum-instances', "The minimum number of instances to run at all times (default 1)") {|i| default_options[:minimum_instances] = i}
          # op.on('-x number', '--maximum-instances', "The maximum number of instances to run (default 3)") {|x| default_options[:maximum_instances] = x}
          # op.on('-w seconds', '--interval-wait-time', "The number of seconds to wait between shutdown or startup of an instance (default 5.minutes)") {|w| default_options[:interval_wait_time] = w}          
          # 
          # op.on_tail("-h", "--help", "Show this message") do |o|
          #   puts "op: #{o}"
          #   exit
          # end          
        end
        Choice.options
      end

      def default_options
        @default_options ||= {
          :run => true,
          :host_port => 7788,
          :client_port => 7788,
          :environment => 'development',
          :debug => true,
          :logging => true,
          :sessions => false,
          :polling_time => "50",
          :interval_wait_time => "300",
          :user_data => "",
          :minimum_instances => 1,
          :maximum_instances => 3,
          :access_key_id => ENV["ACCESS_KEY"],
          :secret_access_key => ENV["SECRET_ACCESS_KEY"],
          :ami => '',
          :command_line => []
        }
      end
      
      def development?
        environment == 'development'
      end
      
      def launching_user_data
        {:polling_time => polling_time}.to_yaml
      end
    
      def method_missing(m,*args)
        options.methods.include?("#{m}") ? options.send(m,args) : super
      end
             
    end
  end
  
  def options
    Application.options
  end
  
end