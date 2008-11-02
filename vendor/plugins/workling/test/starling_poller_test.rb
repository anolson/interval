require File.dirname(__FILE__) + '/test_helper.rb'

context "the starling poller" do
  setup do
    routing = Workling::Starling::Routing::ClassAndMethodRouting.new
   
    # the memoryreturnstore behaves exactly like memcache. 
    @connection = Workling::Return::Store::MemoryReturnStore.new
    @client = Workling::Starling::Poller.new(routing)
  end
  
  specify "should invoke Util.echo with the arg 'hello' if the string 'hello' is set onto the queue utils__echo" do
    Util.any_instance.stubs(:echo).with("hello")
    @connection.set("utils__echo", "hello")
    @client.dispatch!(@connection, Util)
  end
  
  specify "should not explode when listen is called, and stop nicely when stop is called. " do
    connection = mock()
    connection.expects(:active?).at_least_once.returns(true)
    ActiveRecord::Base.expects(:connection).at_least_once.returns(connection)
    
    client = mock()
    client.expects(:get).at_least_once.returns("hi")
    Workling::Starling::Client.expects(:new).at_least_once.returns(client)
    
    # Don't take longer than 10 seconds to shut this down. 
    Timeout::timeout(10) do
      listener = Thread.new { @client.listen }
      @client.stop
      listener.join
    end
    
  end
end