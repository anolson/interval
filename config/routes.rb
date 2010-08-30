ActionController::Routing::Routes.draw do |map|
  map.signin 'signin', 
    :controller => 'sessions',
    :action => 'new'

  map.signout 'signout', 
    :controller => 'sessions',
    :action => 'destroy'
    
  map.signup 'signup', 
    :controller => 'users',
    :action => 'new'
  
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


  map.resources :articles, :as => "support",  :controller => "support", :only => [:index, :show]
  map.resources :downloads
  map.resources :processors
  map.resources :sessions
  
  
  map.resources :workouts do |workout|
    workout.resource :peak_power
    workout.resource :graph    
  end
  
  map.resource :password_change, :controller => 'password_change'
  map.resource :preferences, :member => {:reset_sharing_links => :get, :reset_upload_address => :get}
  map.resource :summary, :controller => "summary"
  map.resource :upload
  map.resource :users, :member => {:confirm_destroy => :get}
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
    
end
