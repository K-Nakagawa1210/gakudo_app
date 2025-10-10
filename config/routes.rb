Rails.application.routes.draw do
  devise_for :users

  root to: "homes#index"
  get "homes", to: "homes#index"

  resources :schools do
    resources :students, only: [:index] do
      collection do
        post :attend
      end
    end
  end
  resources :attendances, only: [:index]
  resources :settings, only: [:index]    # 設定ページ用
end
