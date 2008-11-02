require 'workling/remote/runners/base'

#
#  Runs Jobs over Starling. For exact Instructions on using this runner, see the README.
#
#  Starling is Blaine Cook's Ruby Queueing Server. Jobs are dispatched by placing
#  the on Starling Queues. The Runner takes care of mapping of queue names to worker code. 
#  this is done with Workling::ClassAndMethodRouting, but you can use your own by sublassing Workling::Routing. 
#  Don’t worry about any of this if you’re not dealing directly with the queues.
#
#  There’s a workling-starling-client daemon that polls Starling and then dispatches jobs these to the 
#  responsible workers. If you intend to run this on a remote machine, then just check out your rails project 
#  there and start up the starling client.
#
module Workling
  module Remote
    module Runners
      class StarlingRunner < Workling::Remote::Runners::Base
        cattr_accessor :routing
        cattr_accessor :client
        
        def initialize
          StarlingRunner.client = Workling::Starling::Client.new
          StarlingRunner.routing = Workling::Starling::Routing::ClassAndMethodRouting.new
        end
        
        # enqueues the job onto Starling. 
        def run(clazz, method, options = {})
          StarlingRunner.client.set(@@routing.queue_for(clazz, method), options)
          
          return nil # empty.
          
          rescue MemCache::MemCacheError => e
            # failed to enqueue, raise a workling error so that it propagates upwards
            raise Workling::WorklingError.new("#{e.class.to_s} - #{e.message}")
        end
      end
    end
  end
end