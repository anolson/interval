ActionController::Routing::Routes.draw do |map|
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

  map.signout 'signout', 
    :controller => 'user',
    :action => 'signout'
  
  map.upload 'upload', 
      :controller => 'training_files',
      :action => 'new'

  map.tour 'tour', 
      :controller => 'site', 
      :action => 'tour'
    
  map.root :controller => 'site', :action => 'index'

  map.connect 'shared/private', :controller => 'site', :action => 'index'
  
  


    
  map.connect 'shared/private/:hash/:action/:id.:format',
      :controller => 'shared'

  map.connect 'shared/private/:hash/:action/:id',
        :controller => 'shared'
  
  map.connect 'shared/private/:hash/:action.:format',
          :controller => 'shared'
  
            
  map.connect 'shared', :controller => 'site', :action => 'index'


    
  map.connect 'shared/:user/:action/:id.:format',
    :requirements => { :user => /\w[\w\.\-_@]+/ },
    :controller => 'shared'
  
  map.connect 'shared/:user/:action/:id',
    :requirements => { :user => /\w[\w\.\-_@]+/ },
    :controller => 'shared'

    map.connect 'shared/:user/:action.:format',
      :requirements => { :user => /\w[\w\.\-_@]+/ },
      :controller => 'shared'
   
  map.connect 'workouts/show/:begin/:end/:id.:format', 
      :controller => 'workouts',
      :action => 'show'

  map.namespace(:admin) do |admin|
    admin.resources :articles
  end 

  map.connect '/admin', :controller => 'admin/session', :action => 'new'
  
  map.support_permalink 'support/:permalink', :controller => "support", :action => "show"
  
  map.resources :articles, :as => "support",  :controller => "support", :only => [:index, :show]
  

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
 

    
end
