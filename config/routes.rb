Rails.application.routes.draw do

	root :to => 'messages#index'

	resources :messages

	get '/messages/:id/resend_script', to: 'messages#resend_script', as: 'resend_script'

end
