Rails.application.routes.draw do
  root "searches#index"
  get "/", to: "searches#index"
  post "/", to: "searches#create"
  get "/search", to: "searches#index"
  post "/search", to: "searches#create"
end
