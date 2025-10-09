Rails.application.routes.draw do
  devise_for :users

  root to: "homes#index"
  get "homes", to: "homes#index"

  resources :schools, only: [:index, :show] # 出席登録ページ用
  resources :attendances, only: [:index, :edit, :update] # 出席一覧ページ用
  resources :settings, only: [:index, :edit, :update]    # 設定ページ用
end
