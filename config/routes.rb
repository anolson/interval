ActionController::Routing::Routes.draw do |map|
  map.resources :users

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  map.signin 'signin', 
    :controller => 'user',
    :action => 'signin'
           
  map.signup 'signup', 
    :controller => 'user',
    :action => 'signup'

  map.signout 'signout', 
    :controller => 'user',
    :action => 'signout'
  
  map.signout 'upload', 
      :controller => 'training_files',
      :action => 'new'
  
  map.root :controller => 'site', :action => 'index'
    
    
  # map.connect 'shared/:user',
  #    :controller => 'shared',
  #    :action => 'index'

  map.connect 'shared/:user/:action.:format',
    :controller => 'shared'
     
  map.connect 'shared/:user/:action/:id.:format',
    :controller => 'shared'
  
  map.connect 'shared/:user/:action/:id',
      :controller => 'shared'
      
  
  #map.resources :workouts
   

     
  #map.connect '/workouts',
  #  :controller => 'workouts',
  #  :action => 'index'   
      
  #map.connect 'workouts/:year/:month/:day/daily', 
  #  :controller => 'workouts',
  #  :action => 'index',
  #  :requirements => { :year => /(19|20)\d\d/, :month => /[01]?\d/, :day => /[0-3]?\d/}
  
  #map.connect 'workouts/:year/:month/:day/daily/details', 
  #    :controller => 'workouts',
  #    :action => 'details',
  #    :requirements => { :year => /(19|20)\d\d/, :month => /[01]?\d/, :day => /[0-3]?\d/}




  #map.connect 'workouts/:page', 
  #  :controller => 'workouts',
  #  :action => 'index'


  #map.connect 'workouts/:year/:month/:day/:permalink/show', 
  #  :controller => 'workouts',
  #  :action => 'show',
  #  :requirements => { :year => /(19|20)\d\d/, :month => /[01]?\d/, :day => /[0-3]?\d/}
  
  #map.connect 'workouts/:year/:month/:day/:permalink/graph', 
  #    :controller => 'workouts',
  #    :action => 'graph',
  #    :requirements => { :year => /(19|20)\d\d/, :month => /[01]?\d/, :day => /[0-3]?\d/}  
        
  #map.connect 'workouts/:year/:month/:day/daily/:action', 
  #  :controller => 'workouts'

  map.connect 'workouts/show/:begin/:end/:id.:format', 
      :controller => 'workouts',
      :action => 'show'

  map.connect '/admin', :controller => 'admin/session', :action => 'new'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
 

    
end
