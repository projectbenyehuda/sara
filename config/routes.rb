Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'welcome#index'

  resource :welcome, only: :index
  get 'welcome/query_by_filter', as: 'query_by_filter'
  get 'welcome/autocomplete_by_filter_tag', as: 'autocomplete_by_filter_tag'
  match 'welcome/search', as: 'search', via: [:get, :post]
  match 'welcome/suggest', as: 'suggest', via: [:get, :post]
  match 'welcome/search_disambig', as: 'search_disambig', via: [:get, :post]
  resources :timelines, only: :index do
    collection do
      get :data
    end
  end
end
