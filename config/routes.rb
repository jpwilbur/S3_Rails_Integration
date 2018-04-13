Rails.application.routes.draw do

	resources :uploads	
	root 'uploads#new'
end
