Rails.application.routes.draw do
  devise_for :users
  resource :dashboard, only: [:show] do
    post 'configreload'
  end
  resources :domains do
    resources :accounts
  end
  scope '/api/v1' do
    defaults format: :json do
      get 'backup', to: 'import_export_api#backup'
      get 'export', to: 'import_export_api#export'
      post 'import', to: 'import_export_api#import'
    end
    defaults format: :text do
      post 'roundcube_password', to: 'roundcube_api#update_password'
    end
  end
  root to: 'dashboards#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
