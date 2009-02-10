
module PoolParty
  module Vb
    class VbCapistrano
      include ::Capistrano::Configuration::Actions::Invocation

      def initialize
        create_config
      end

      # Create the config for capistrano
      # This is a dynamic capistrano configuration file
      def create_config
        @config = ::Capistrano::Configuration.new
        @config.logger = ::Capistrano::Logger.new
        @config.logger.level = ::Capistrano::Logger::MAX_LEVEL

        capfile = returning Array.new do |arr|
          Dir["#{::File.dirname(__FILE__)}/recipies/*.rb"].each {|a| arr << "require '#{a}'" }
          #arr << "ssh_options[:keys] = '#{@cloud.full_keypair_basename_path}'"

          arr << "role :apps, \"toy.local\""
        end.join("\n")

        @config.load(:string => capfile)
        @config.set(:user, "root")
      end

      def run_ls
        x= @config.ls
        pp x
      end

      def capture_ls
        x= @config.ls_g
        pp x
      end


    end
  end
end
