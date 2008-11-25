require 'optparse' 
require "poolparty"
require "poolpartycl"
require 'rdoc/usage'
require 'ostruct'
require 'date'

module PoolParty
  class Optioner
    include Configurable
    include MethodMissingSugar
        
    def initialize(args=[], opts={}, &block)
      @arguments = parse_args(args)      
      @extra_help = opts.has_key?(:extra_help) ? opts[:extra_help] : ""
      @abstract = opts[:abstract] ? opts[:abstract] : false
      @parse_options = opts[:parse_options] ? opts[:parse_options] : !@abstract
      @command = opts[:command] ? opts[:command] : false
      
      parse_options(&block) if @parse_options
      set_default_options
      self
    end
    
    def daemonizeable
      @opts.on('-d', '--daemonize', 'Daemonize starting the cloud')    { self.daemon true }
    end
    def cloudnames
      @opts.on('-n cloudname', '--name name', 'Start cloud by this name')    { |c| self.cloudname c }
    end
    
    def parse_args(argv, safe=[])
      argv
    end
    
    def parent
      self
    end
    
    def set_default_options
      self.verbose false
      self.quiet false
    end
    
    def parse_options(&blk)
      progname = $0.include?("-") ? "#{::File.basename($0[/(\w+)-/, 1])} #{::File.basename($0[/-(.*)/, 1])}" : ::File.basename($0)
      @opts = OptionParser.new 
      @opts.banner = "Usage: #{progname} #{@abstract ? "[command] " : ""}[options]"

      @opts.separator ""
      
      unless @abstract
        @opts.separator "Options:"
        
        @opts.on('-v', '--verbose', 'Be verbose')    { self.verbose true }  
        @opts.on('-s [file]', '--spec-file [file]', 'Set the spec file')      { |file| self.spec file.chomp }
        @opts.on('-t', '--test', 'Testing mode')    { self.testing true }

        blk.call(@opts, self) if blk
      end
      
      @opts.on('-V', '--version', 'Display the version')    { puts @version ; exit 0 }
      @opts.on_tail("-h", "--help", "Show this message") do
        puts @opts
        puts @extra_help
        exit
      end
      
      @opts.parse(@arguments.dup)
      
      process_options
      output_options if verbose
      unless @abstract
        self.loaded_pool load_pool(self.spec || Binary.get_existing_spec_location)

        self.loaded_clouds extract_cloud_from_options(self)
        self.loaded_pools extract_pool_from_options(self)

        reject_junk_options!
        raise CloudNotFoundException.new("Please specify your cloud with -s, move it to ./pool.spec or in your POOL_SPEC environment variable") unless loaded_clouds && !loaded_clouds.empty?
        loaded_pools.each do |pl|
          pl.configure(self.options)
        end
        loaded_clouds.each do |cl|
          cl.configure(self.options)
        end
      end
    end
    def reject_junk_options!
      %w(loaded_pool cloudname extract_pool_from_options).each do |opt|
        @options.delete(opt.to_sym)
      end
    end
    def process_options
    end
        
    def output_version
      puts @version
    end
    
  end
  
  def extract_cloud_from_options(o)
    o.cloudname ? [cloud(o.cloudname.downcase.to_sym)] : clouds.collect {|n,cl| cl}
  end
  
  def extract_pool_from_options(o)
    o.poolname ? [pool(o.poolname.downcase.to_sym)] : pools.collect {|n,pl| pl}
  end
end