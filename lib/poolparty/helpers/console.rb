module PoolParty
  module Console
    
    # Load a file that contains a pool into memory
    def load_pool(filename)
      PoolParty::Script.inflate(open(filename).read, File.dirname(filename))
    end
    
    # Clear all the pools and reload the console
    # Call within console to reset and reload the entire poolparty base
    # as well
    def reload!      
      reset!
    end
        
    def pool_print(options={})
      pools.each do |k,v|
        print v.pretty_print
      end
      puts ""
      pools.size
    end
    
  end
end

class Object
  include PoolParty::Console
end