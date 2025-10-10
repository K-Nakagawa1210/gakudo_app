Rails.application.routes.draw do
  devise_for :users

  root to: "homes#index"
  get "homes", to: "homes#index"

  resources :schools, only: [:index, :show] do
    resources :students, only: [:index] do
      collection do
        post :attend
      end
    end
  end
  resources :attendances, only: [:index]
  resources :settings, only: [:index, :edit, :update]    # 設定ページ用
end
