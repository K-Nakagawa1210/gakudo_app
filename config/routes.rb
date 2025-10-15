Rails.application.routes.draw do
  devise_for :users

  root to: "homes#index"
  get "homes", to: "homes#index"
  get 'settings', to: 'settings#index'

  resources :schools do
    resources :students, only: [:index] do
      collection do
        get :attend             # 出席画面表示
        post :attend_create     # 出席登録
        post :leave             # 帰宅登録
        get :index_by_school    # 学校ごとの児童一覧
      end
    end

    collection do
      get :attendance_index, to: "schools#attendance_index"
    end
  end

  resources :attendances, only: [:index, :edit, :update] do
    collection do
      get :export_xlsx
    end
  end

  resources :settings, only: [:index]
  resources :students, except: [:show] do
    collection do
      get :manage  # 児童設定ページ（学校に依存しない）
    end
  end
end
