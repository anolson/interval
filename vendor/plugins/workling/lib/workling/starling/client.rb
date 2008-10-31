require 'workling/starling'

#
#  Wrapper for the starling connection. The connection is made using fiveruns-memcache-client, 
#  or memcache-client, if this is not available. See the README for a discussion of the memcache 
#  clients. 
#
#  method_missing delegates all messages through to the underlying memcache connection. 
#
module Workling
  module Starling
    class Client
      
      # the url with which the memcache client expects to reach starling
      attr_accessor :starling_urls
      
      # the memcache connection object
      attr_accessor :connection
      
      #
      #  the client attempts to connect to starling using the configuration options found in 
      #
      #      Workling::Starling.config. this can be configured in config/starling.yml. 
      #
      #  the initialization code will raise an exception if memcache-client cannot connect 
      #  to starling.
      #
      def initialize
        @starling_urls = Workling::Starling.config[:listens_on].split(',').map { |url| url ? url.strip : url }
        options = [@starling_urls, Workling::Starling.config[:memcache_options]].compact
        @connection = ::MemCache.new(*options)
        
        raise_unless_connected!
      end
      
      # delegates directly through to the memcache connection. 
      def method_missing(method, *args)
        @connection.send(method, *args)
      end
      
      private
        # make sure we can actually connect to starling on the given port
        def raise_unless_connected!
          begin 
            @connection.stats
          rescue
            raise Workling::StarlingNotFoundError.new
          end
        end
    end
  end
end