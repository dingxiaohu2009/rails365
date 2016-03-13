require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :users
  root to: 'home#index'

  resources :articles
  resources :groups

  namespace :admin do
    root to: "articles#index"
    resources :sites, except: [:show]
    resources :site_infos, only: [:index, :update, :edit]
    resources :exception_logs, only: [:show, :destroy, :index] do
      delete :destroy_multiple, on: :collection
    end
    resources :sidekiq_exceptions, only: [:show, :destroy, :index] do
      delete :destroy_multiple, on: :collection
    end
  end

  %w(404 422 500).each do |code|
    get code, to: "errors#show", code: code
  end

  patch '/photos', to: "photos#create"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["USERNAME"] && password == ENV['PASSWORD']
  end if Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'
  mount PgHero::Engine, at: "pghero"
end
