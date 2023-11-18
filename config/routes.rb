Rails.application.routes.draw do
  get 'blip/new'
  get 'blip/create'
  get 'blip/show'
  devise_for :users
  resources :links
  root to: "links#index"
  get '/:link_id', to: 'links#id_search'
  get '/:link_id/edit', to: 'links#edit', as: 'link_edit'
  get '/user/profile', to: 'links#profile'
  get '/pages/:page', to: 'links#index', as: 'paginate_links'
  get '/download/export_to_csv', to: 'links#export_to_csv', as: :export_to_csv
  resources :blip, only: [:new, :create, :index, :show]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
