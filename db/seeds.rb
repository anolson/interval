#default admin role
role = Role.create(:name => 'admin', :description => 'Role for all administrators.')

#default admin user, change the password in production
user = User.new(
  :username => 'admin', 
  :password => '8OkOmke1FK7n', 
  :password_confirmation => '8OkOmke1FK7n', 
  :terms_of_service => true, 
  :email => 'admin@localhost')
  
user.roles << role
user.save