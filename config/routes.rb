ActionController::Routing::Routes.draw do |map|
  map.signin 'signin', 
    :controller => 'user',
    :action => 'signin'

  map.signout 'signout', 
    :controller => 'user',
    :action => 'signout'
  
  map.tour 'tour', 
      :controller => 'site', 
      :action => 'tour'
      
  map.admin '/admin', 
    :controller => 'admin/session', 
    :action => 'new'

  map.support_permalink 'support/:permalink', 
    :controller => "support", 
    :action => "show"
    
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

  map.namespace(:admin) do |admin|
    admin.resources :articles
  end 

  map.resources :workouts do |workout|
    workout.resource :peak_power
    workout.resource :graph
  end
  
  map.resource :upload
  map.resource :summary, :controller => "summary"
  map.resource :preferences, :member => {:reset_sharing_links => :get, :reset_upload_address => :get}

  map.resources :articles, :as => "support",  :controller => "support", :only => [:index, :show]
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
    
end
