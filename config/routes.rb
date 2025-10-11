Rails.application.routes.draw do
  devise_for :users

  root to: "homes#index"
  get "homes", to: "homes#index"
  get 'settings', to: 'settings#index'

  resources :schools do
    resources :students, only: [] do
      collection do
        get :attend             # 出席画面表示
        post :attend            # 出席登録
        get :index_by_school    # 学校ごとの児童一覧
      end
    end
  end
  resources :attendances, only: [:index]
  resources :settings, only: [:index]
  resources :students, except: [:show] 
end
