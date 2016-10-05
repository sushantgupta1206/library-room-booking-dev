Rails.application.routes.draw do
  get 'user/home'

  get 'user/manage_bookings'

  get '/'      =>   'library#index'
  get '/signup' => 'library#signup'
  post 'library/new_user' => 'library#new_user'

  post '/library/login' =>    'library#login'
  post 'admin/add_booking' => 'admin#add_booking'
  post 'admin/new_admin' => 'admin#new_admin'
  post 'admin/new_user' => 'admin#new_user'
  post 'admin/new_room' => 'admin#new_room'
  post 'admin/save_changes' => 'admin#save_profile_changes'
  post 'admin/save_admin_changes' => 'admin#save_admin_changes'
  post 'admin/save_user_changes' => 'admin#save_user_changes'
  post 'admin/save_room_changes' => 'admin#save_room_changes'
  post 'user/search_results' => 'user#search_results'
  post 'user/add_booking' => 'user#add_booking'
  get 'admin/home'

  post 'user/save_profile_changes' => 'user#save_profile_changes'

  get 'admin/manage_users'
  get 'admin/manage_admins'
  get 'admin/create_admin'
  get 'admin/create_user'
  get 'admin/manage_rooms'

  get 'admin/manage_bookings'

  get '/admin/delete_booking/:id' => 'admin#delete_booking'
  get '/admin/delete_admin/:id' => 'admin#delete_admin'
  get '/admin/edit_admin/:id' => 'admin#edit_admin'
  get '/admin/edit_user/:id' => 'admin#edit_user'
  get '/admin/delete_user/:id' => 'admin#delete_user'
  get 'admin/show_user_bookings/:id' => 'admin#show_user_bookings'
  get 'admin/delete_user_bookings/:id' => 'admin#delete_user_bookings'
  get 'admin/delete_a_user_booking/:id' => 'admin#delete_a_user_booking'
  get 'admin/show_room_bookings/:id' => 'admin#show_room_bookings'
  get 'admin/delete_a_room_booking/:id' => 'admin#delete_a_room_booking'
  get 'admin/delete_room_bookings/:id' => 'admin#delete_room_bookings'
  get 'admin/delete_room/:id' => 'admin#delete_a_room'

  get '/admin/create_booking/:id' => 'admin#create_booking'
  get 'admin/create_room/:id' => 'admin#create_room'
  get '/admin/edit_room/:id' => 'admin#edit_room'
  get '/admin/edit_profile'
  get '/admin/logout'
  get 'admin/url_tampered'


  get '/user/edit_profile'
  get 'user/search'
  get 'user/create_booking/:id' => 'user#create_booking'
  get 'user/new_booking/:id' => 'user#new_booking'
  get 'user/delete_booking/:id' => 'user#delete_booking'
  get 'user/delete_user_booking/:id' => 'user#delete_user_booking'
  get 'user/url_tampered'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
