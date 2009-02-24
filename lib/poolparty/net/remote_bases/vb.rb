=begin rdoc
  Virtualbox Remoter Base
  
  This serves as the basis for running PoolParty on Virtualbox cloud
  cluster. 
=end
require "pp"
require "date"
# To make Resolv aware of mDNS
#require 'net/dns/resolv-mdns'
# To make TCPSocket use Resolv, not the C library resolver.
#require 'net/dns/resolv-replace'



require "#{::File.dirname(__FILE__)}/vb/vb_capistrano"


class String
  def parse_datetime
    DateTime.parse( self.chomp ) rescue self
  end
end
module PoolParty
  module Vb
    include PoolParty::Remote::RemoterBase
      
    def launch_new_instance!(num=1)
      #        instance = ec2.run_instances(
      #          :image_id => (ami || Base.ami),
      #          :user_data => "",
      #          :minCount => 1,
      #          :maxCount => num,
      #          :key_name => (keypair || Base.keypair),
      #          :availability_zone => (availabilty_zone || Base.availabilty_zone),
      #          :instance_type => "#{size || Base.size}",
      #          :group_id => ["#{security_group || Base.security_group}"])
      begin

        #        h = VbCapistrano.new
        #        h.run_ls
        
        #          h = EC2ResponseObject.get_hash_from_response(instance)
        h=         {
          :instance_id => "1",
          :name => "masterr",
          :ip => "192.168.1.6" ,
          :status => "running", # resp.instanceState.name,
          :launching_time =>  Date.today.to_s.parse_datetime , #resp.launchTime.parse_datetime,
          :internal_ip => "192.168.1.6",#Resolv::DNS.new.getaddress("poolparty.local").to_s,
          :keypair => "netociety_app",
          :security_group => "group"
        }
        #h = instance.instancesSet.item.first
      rescue Exception => e
        pp e
        #  h = instance
      end
      h
    end
    # Terminate an instance by id
    def terminate_instance!(instance_id=nil)
      #        ec2.terminate_instances(:instance_id => instance_id)
    end
    # Describe an instance's status
    def describe_instance(id=nil)
      describe_instances.select {|a| a[:name] == id}[0] rescue nil
    end
    def describe_instances
      id = 0
      x = get_instances_description.each_with_index do |h,i|
        if h[:status] == "running"
          inst_name = id == 0 ? "master" : "node#{id}"
          id += 1
        else
          inst_name = "#{h[:status]}_node#{i}"
        end
        h.merge!({
            :name => inst_name,
            :hostname => h[:ip],
            :ip => "192.168.1.6",#Resolv.getaddress(h[:ip]).to_s,
            :index => i,
            :launching_time => (h[:launching_time])
          })
      end.sort {|a,b| a[:index] <=> b[:index] }
    end
    # Get the s3 description for the response in a hash format
    def get_instances_description
      [{
          #:instance_id => "resp.instanceId",
          #:name => "resp.instanceId",
          :ip => "192.168.1.6" ,
          :status => "running", # resp.instanceState.name,
          :launching_time =>  Date.today.to_s.parse_datetime , #resp.launchTime.parse_datetime,
          :internal_ip => "192.168.1.6", #Resolv::MDNS.new.getaddress("poolparty.local").to_s,
          :keypair => "netociety_app",
          :security_group => "group"
        }]
      #        EC2ResponseObject.get_descriptions(ec2.describe_instances)
    end

    def after_launch_master(inst=nil)
      instance = master
      vputs "Running tasks after launching the master"
      begin
        pp instance
        # when_no_pending_instances do
        if instance
          #              ec2.attach_volume(:volume_id => ebs_volume_id, :instance_id => instance.instance_id, :device => ebs_volume_device) if ebs_volume_id && ebs_volume_mount_point
          # Let's associate the address LAST so that we can still connect to the instance
          # for the other tasks here
          #              ec2.associate_address(:instance_id => instance.instance_id, :public_ip => set_master_ip_to) if set_master_ip_to
          reset_remoter_base!
        end
        # end
      rescue Exception => e
        vputs "Error in after_launch_master: #{e}"
      end
      reset_remoter_base!
      when_all_assigned_ips {wait "5.seconds"}
    end

    # Help create a keypair for the cloud
    # This is a helper to create the keypair and add them to the cloud for you
    def create_keypair
      return false unless keypair
      unless ::File.exists?( new_keypair_path )
        FileUtils.mkdir_p ::File.dirname( new_keypair_path )
        vputs "Creating keypair: #{keypair} in #{new_keypair_path}"
        Kernel.system "ec2-add-keypair #{keypair} > #{new_keypair_path} && chmod 600 #{new_keypair_path}"
      end
    end
      
    # wrapper for remote base to perform a snapshot backup for the ebs volume
    def create_snapshot
      return nil if ebs_volume_id.nil?
      #       ec2.create_snapshot(:volume_id => ebs_volume_id)
    end
      
    # EC2 connections
    #      def ec2
    #        @ec2 ||= EC2::Base.new( :access_key_id => (access_key || Base.access_key),
    #                                :secret_access_key => (secret_access_key || Base.secret_access_key)
    #                              )
    #      end
      
    def before_configuration_tasks
      if has_cert_and_key?
        # copy_file_to_storage_directory(pub_key)
        # copy_file_to_storage_directory(private_key)
      end
    end
    def has_cert_and_key?
      pub_key && private_key
    end
    # The keys are used only for puppet certificates
    # and are only used for EC2. These should be abstracted
    # eventually into the ec2 remoter_base
    # Public key
    def pub_key
      @pub_key ||= ENV["EC2_CERT"] ? ENV["EC2_CERT"] : nil
    end
    # Private key
    def private_key
      @private_key ||= ENV["EC2_PRIVATE_KEY"] ? ENV["EC2_PRIVATE_KEY"] : nil
    end

    # Hook
    #TODO#: Change this so they match with the cap tasks

    def after_install_tasks_for(o)
      [
      ]
    end

    def reset_base!
      @describe_instances = @cached_descriptions = nil
    end
  end
  register_remote_base :Vb
end

