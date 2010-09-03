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

  map.namespace(:admin) do |admin|
    admin.resources :articles
    admin.resources :users
    
    admin.resource :sessions
  end 

  #/shared and /shared/private to the main site
  map.connect 'shared', :controller => 'site', :action => 'index'
  map.connect 'shared/private', :controller => 'site', :action => 'index'

  map.namespace(:shared) do |shared|
    #connect the old urls
    shared.connect ':user', :controller => 'workouts'
    shared.connect 'private/:hash', :controller => 'workouts'
    
    #private sharing
    shared.resources :private_workouts, :path_prefix => 'shared/private/:hash', :as => "workouts", :controller => "workouts" do |workouts|
      workouts.resource :graph
    end
    shared.resources :private_downloads, :path_prefix => 'shared/private/:hash', :as => 'downloads', :controller => 'downloads'
    
    #public sharing
    shared.resources :workouts, :path_prefix => 'shared/:user', :requirements => { :user => /\w[\w\.\-_@]+/ } do |workouts|
      workouts.resource :graph
    end
    shared.resources :downloads, :path_prefix => 'shared/:user', :requirements => { :user => /\w[\w\.\-_@]+/ }
    
  end

  map.resources :articles, :as => "support",  :controller => "support", :only => [:index, :show]
  map.resources :downloads
  map.resources :processors

  
  map.resources :workouts do |workout|
    workout.resource :peak_power
    workout.resource :graph    
  end
  
  map.resource :password_change, :controller => 'password_change'
  map.resource :preferences, :member => {:reset_sharing_links => :get, :reset_upload_address => :get}
  map.resource :sessions  
  map.resource :summary, :controller => "summary"
  map.resource :upload
  map.resource :users, :member => {:confirm_destroy => :get}
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
    
end
