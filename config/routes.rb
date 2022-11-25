Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'welcome#index'

  resource :welcome, only: :index
  get 'welcome/query_by_filter', as: 'query_by_filter'
  get 'welcome/autocomplete_by_filter_tag', as: 'autocomplete_by_filter_tag'
  match 'welcome/search', as: 'search', via: [:get, :post]
  match 'welcome/suggest', as: 'suggest', via: [:get, :post]
  match 'welcome/search_disambig', as: 'search_disambig', via: [:get, :post]
  match 'outline/:id' => 'projects#outline', as: 'outline', via: [:get, :post]
  match 'outline_download/:id' => 'projects#outline_download', as: 'outline_download', via: [:get]

  resources :queries, only: [:show, :destroy] do
    member do
      get 'show'
      post 'show'
    end
  end

  resources :projects, except: [:new] do
    resources :queries, only: [:create]
    resources :ignored_items, only: [:create]
  end

  resources :ignored_items, only: [:destroy]

  resources :response_items, only: [] do
    member do
      post :toggle_favorite
    end
  end

  resources :timelines, only: :index do
    collection do
      get :data
    end
  end
end
