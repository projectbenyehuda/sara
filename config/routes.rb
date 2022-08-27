Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'welcome#index'

  resource :welcome, only: :index
  resources :timelines, only: :index do
    collection do
      get :data
    end
  end
end
