Rails.application.routes.draw do
  devise_for :users
  resource :dashboard, only: [:show]
  resources :domains do
    resources :accounts
  end
  defaults format: :json do
    scope '/api/v1' do
      get 'backup', to: 'import_export_api#backup'
      get 'export', to: 'import_export_api#export'
      post 'import', to: 'import_export_api#import'
    end
  end
  root to: 'dashboards#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
