require 'workling/starling'

#
#  Polls Starling and dispatches jobs onto the correct workers.
#  
#  TODO: needs some urgent refactoring love. 
# 
module Workling
  module Starling
    class Poller
      
      # Seconds to sleep before looping
      cattr_accessor :sleep_time
      
      # Seconds to wait while resetting connection
      cattr_accessor :reset_time 

      def initialize(routing)
        Poller.sleep_time = Workling::Starling.config[:sleep_time] || 2
        Poller.reset_time = Workling::Starling.config[:reset_time] || 30
          
        @routing = routing
        @workers = ThreadGroup.new
        @mutex = Mutex.new
      end      
      
      # returns the Workling::Base.logger
      def logger; Workling::Base.logger; end
    
      def listen
                
        # Allow concurrency for our tasks
        ActiveRecord::Base.allow_concurrency = true

        # Create a thread for each worker.
        Workling::Discovery.discovered.each do |clazz|
          logger.debug("Discovered listener #{clazz}")
          @workers.add(Thread.new(clazz) { |c| clazz_listen(c) })
        end
        
        # Wait for all workers to complete
        @workers.list.each { |t| t.join }

        logger.debug("Reaped listener threads. ")
        
        # Clean up all the connections.
        ActiveRecord::Base.verify_active_connections!
        logger.debug("Cleaned up connection: out!")
      end
      
      # Check if all Worker threads have been started. 
      def started?
        Workling::Discovery.discovered.size == @workers.list.size
      end
      
      # Gracefully stop processing
      def stop
        sleep 1 until started? # give it a chance to start up before shutting down. 
        logger.info("Giving Listener Threads a chance to shut down. This may take a while... ")
        @workers.list.each { |w| w[:shutdown] = true }
        logger.info("Listener threads were shut down.  ")
      end

      # Listen for one worker class
      def clazz_listen(clazz)
        logger.debug("Listener thread #{clazz.name} started")
           
        # Read thread configuration if available
        if Starling.config.has_key?(:listeners)
          if Starling.config[:listeners].has_key?(clazz.to_s)
            config = Starling.config[:listeners][clazz.to_s].symbolize_keys
            thread_sleep_time = config[:sleep_time] if config.has_key?(:sleep_time)
          end
        end

        hread_sleep_time ||= self.class.sleep_time
                
        # Setup connection to starling (one per thread)
        connection = Workling::Starling::Client.new
        logger.info("** Starting Workling::Starling::Client for #{clazz.name} queue")
        
        # Start dispatching those messages
        while (!Thread.current[:shutdown]) do
          begin
            
            # Thanks for this Brent! 
            #
            #     ...Just a heads up, due to how rails’ MySQL adapter handles this  
            #     call ‘ActiveRecord::Base.connection.active?’, you’ll need 
            #     to wrap the code that checks for a connection in in a mutex.
            #
            #     ....I noticed this while working with a multi-core machine that 
            #     was spawning multiple workling threads. Some of my workling 
            #     threads would hit serious issues at this block of code without 
            #     the mutex.            
            #
            @mutex.synchronize do 
              unless ActiveRecord::Base.connection.active?  # Keep MySQL connection alive
                unless ActiveRecord::Base.connection.reconnect!
                  logger.fatal("Failed - Database not available!")
                  break
                end
              end
            end

            # Dispatch and process the messages
            n = dispatch!(connection, clazz)
            logger.debug("Listener thread #{clazz.name} processed #{n.to_s} queue items") if n > 0
            sleep(self.class.sleep_time) unless n > 0
            
            # If there is a memcache error, hang for a bit to give it a chance to fire up again
            # and reset the connection.
            rescue MemCache::MemCacheError
              logger.warn("Listener thread #{clazz.name} failed to connect to memcache. Resetting connection.")
              sleep(self.class.reset_time)
              connection.reset
          end
        end
        
        logger.debug("Listener thread #{clazz.name} ended")
      end
      
      # Dispatcher for one worker class. Will throw MemCacheError if unable to connect.
      # Returns the number of worker methods called
      def dispatch!(connection, clazz)
        n = 0
        for queue in @routing.queue_names_routing_class(clazz)
          begin
            result = connection.get(queue)
            if result
              n += 1
              handler = @routing[queue]
              method_name = @routing.method_name(queue)
              logger.debug("Calling #{handler.class.to_s}\##{method_name}(#{result.inspect})")
              handler.dispatch_to_worker_method(method_name, result)
            end
          rescue MemCache::MemCacheError => e
            logger.error("FAILED to connect with queue #{ queue }: #{ e } }")
            raise e
          end
        end
        
        return n
      end
    end
  end
end
