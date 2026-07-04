Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post 'auth/register', to: 'auth#register'
      post 'auth/login',    to: 'auth#login'
      get  'auth/me',       to: 'auth#me'

      resources :boards do
        resources :lists, shallow: true do
          resources :cards, shallow: true
        end
      end
    end
  end
end
