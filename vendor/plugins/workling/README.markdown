# Workling

Workling gives your Rails App a simple API that you can use to make code run in the background, outside of the your request. 

You can configure how the background code will be run. Currently, workling supports Starling, BackgroundJob and Spawn Runners. Workling is a bit like Actve* for background work: you can write your code once, then swap in any of the supported background Runners later. This keeps things flexible. 

## Installing Workling

The easiest way of getting started with workling is like this: 

    script/plugin install git://github.com/purzelrakete/workling.git
    script/plugin install git://github.com/tra/spawn.git 

If you're on an older Rails version, there's also a subversion mirror wor workling (I'll do my best to keep it synched) at:

    script/plugin install http://svn.playtype.net/plugins/workling/

## Writing and calling Workers

This is pretty easy. Just put `cow_worker.rb` into into `app/workers`, and subclass `Workling::Base`:

    # handle asynchronous mooing.
    class CowWorker < Workling::Base 
      def moo(options)
        cow = Cow.find(options[:id])
        logger.info("about to moo.")
        cow.moo
      end
    end

Make sure you have exactly one hash parameter in your methods, workling passes the job :uid into here. Btw, in case you want to follow along with the Mooing, grab 'cows-not-kittens' off github, it's an example workling project. Look at the branches, there's one for each Runner.

Next, you'll want to call your workling in a controller. Your controller might looks like this: 

    class CowsController < ApplicationController
  
      # milking has the side effect of causing
      # the cow to moo. we don't want to
      # wait for this while milking, though,
      # it would be a terrible waste ouf our time.
      def milk
        @cow = Cow.find(params[:id])
        CowWorker.asynch_moo(:id => @cow.id)
      end
    end

Notice the `asynch_moo` call to `CowWorker`. This will call the `moo` method on the `CowWorker` in the background, passing any parameters you like on. In fact, workling will call whatever comes after asynch_ as a method on the worker instance. 

## Worker Lifecycle

All worker classes must inherit from this class, and be saved in `app/workers`. The Worker is loaded once, at which point the instance method `create` is called. 

Calling `async_my_method` on the worker class will trigger background work. This means that the loaded Worker instance will receive a call to the method `my_method(:uid => "thisjobsuid2348732947923")`. 

## Exception handling in Workers

If an exception is raised in your Worker, it will not be propagated to the calling code by workling. This is because the code is called asynchronously, meaning that exceptions may be raised after the calling code has already returned. If you need your calling code to handle exceptional situations, you have to pass the error into the return store. 

Workling does log all exceptions that propagate out of the worker methods. 

## Logging with Workling

`RAILS_DEFAULT_LOGGER` is available in all workers. Workers also have a logger method which returns the default logger, so you can log like this: 

    logger.info("about to moo.")

## What should I know about the Spawn Runner?

Workling automatically detects and uses Spawn, if installed. Spawn basically forks Rails every time you invoke a workling. To see what sort of characteristics this has, go into script/console, and run this: 

    >> fork { sleep 100 } 
    => 1060 (the pid is returned)

You'll see that this executes pretty much instantly. Run 'top' in another terminal window, and look for the new ruby process. This might be around 30 MB. This tells you that using spawn as a runner will result low latency, but will take at least 30MB for each request you make. 

You cannot run your workers on a remote machine or cluster them with spawn. You also have no persistence: if you've fired of a lot of work and everything dies, there's no way of picking up where you left off. 

# Using the Starling runner instead of Spawn

If you want cross machine jobs with low latency and a low memory overhead, you might want to look into using the Starling Runner. 

## Installing Starling

As of 27. September 2008, the recommended Starling setup is as follows:

    gem sources -a http://gems.github.com/ 
    sudo gem install starling-starling 
    mkdir /var/spool/starling 

The robot Co-Op Memcached Gem version 1.5.0 has several bugs, which have been fixed in the fiveruns-memcache-client gem. The starling-starling gem will install this as a dependency. Refer to the fiveruns README to see what the exact fixes are. 

The Rubyforge Starling gem is also out of date. Currently, the most authorative Project is starling-starling on github (27. September 2008). 

Workling will now automatically detect and use Starling, unless you have also installed Spawn. If you have Spawn installed, you need to tell Workling to use Starling by putting this in your environment.rb: 

    Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new

## Starting up the required processes

Here's what you need to get up and started in development mode. Look in config/starling.yml to see what the default ports are for other environments. 

    sudo starling -d -p 22122
    script/workling_starling_client start

## Configuring starling.yml

Workling copies a file called starling.yml into your applications config directory. You can delete this file if you're not planning to use Starling. The config file tells Workling on which port Starling is listening. 

Notice that the default production port is 15151. This means you'll need to start Starling with -p 15151 on production. 

You can also use this config file to pass configuration options to the memcache client which workling uses to connect to starling. use the key 'memcache_options' for this. 

You can also set sleep time for each Worker. See the key 'listeners' for this. Put in the modularized Class name as a key. 

    development:
      listens_on: localhost:22122
      sleep_time: 2
      reset_time: 30
      listeners:
        Util:
          sleep_time: 20
      memcache_options:
        namespace: myapp_development
        
    production:
      listens_on: localhost:22122, localhost:221223, localhost:221224
      sleep_time: 2
      reset_time: 30
      
Note that you can cluster Starling instances by passing a comma separated list of values to 
        
Sleep time determines the wait time between polls against polls. A single poll will do one .get on every queue (there is a corresponding queue for each worker method).

If there is a memcache error, the Poller will hang for a bit to give it a chance to fire up again and reset the connection. The wait time can be set with the key reset_time.

## Seeing what Starling is doing

Starling comes with it's own script, starling_top. If you want statistics specific to workling, run:

    script/starling_status.rb

## A Quick Starling Primer

You might wonder what exactly starling does. Here's a little snippet you can play with to illustrate how it works: 

     4 # Put messages onto a queue:
     5 require 'memcache'
     6 starling = MemCache.new('localhost:22122')
     7 starling.set('my_queue', 1)
     8 
     9 # Get messages from the queue:
    10 require 'memcache'
    11 starling = MemCache.new('localhost:22122')
    12 loop { puts starling.get('my_queue') }
    13

# Using BackgroundJob

If you don't want to bother with seperate processes, are not worried about latence or memory footprint, then you might want to use Bj to power workling. 

Install the Bj plugin like this:

    1 ./script/plugin install http://codeforpeople.rubyforge.org/svn/rails/plugins/bj
    2 ./script/bj setup

Workling will now automatically detect and use Bj, unless you have also installed Starling. If you have Starling installed, you need to tell Workling to use Bj by putting this in your environment.rb: 

    Workling::Remote.dispatcher = Workling::Remote::Runners::BackgroundjobRunner.new

# Progress indicators and return stores

Your worklings can write back to a return store. This allows you to write progress indicators, or access results from your workling. As above, this is fairly slim. Again, you can swap in any return store implementation you like without changing your code. They all behave like memcached. For tests, there is a memory return store, for production use there is currently a starling return store. You can easily add a new return store (over the database for instance) by subclassing `Workling::Return::Store::Base`. Configure it like this in your test environment:

    Workling::Return::Store.instance = Workling::Return::Store::MemoryReturnStore.new
    
Setting and getting values works as follows. Read the next paragraph to see where the job-id comes from. 

    Workling.return.set("job-id-1", "moo")
    Workling.return.get("job-id-1")           => "moo"

Here is an example worker that crawls an addressbook and puts results into a return store. Workling makes sure you have a :uid in your argument hash - set the value into the return store using this uid as a key:

    require 'blackbook'
    class NetworkWorker < Workling::Base
      def search(options)
        results = Blackbook.get(options[:key], options[:username], options[:password])
        Workling.return.set(options[:uid], results)
      end
    end

call your workling as above: 

    @uid = NetworkWorker.asynch_search(:key => :gmail, :username => "foo@gmail.com", :password => "bar")

you can now use the @uid to query the return store:   

    results = Workling.return.get(@uid)

of course, you can use this for progress indicators. just put the progress into the return store. 

enjoy!

# Contributors

The following people contributed code to workling so far. Many thanks :) If I forgot anybody, I aplogise. Just drop me a note and I'll add you to the project so that you can amend this!

Anybody who contributes fixes (with tests), or new functionality (whith tests) which is pulled into the main project, will also be be added to the project.

* Andrew Carter (ascarter)
* Chris Gaffney (gaffneyc)
* Matthew Rudy (matthewrudy)
* Larry Diehl (reeze)
* grantr (francios)
* David (digitalronin)
* Dave Dupré
* Douglas Shearer (dougal)
* Nick Plante (zapnap)
* Brent
* Evan Light (elight)

Copyright (c) 2008 play/type GmbH, released under the MIT license
