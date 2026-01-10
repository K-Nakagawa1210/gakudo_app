require 'rails_helper'

RSpec.describe "ユーザー登録", type: :system do
  before do
    # 必要に応じて、JSを動かすブラウザ設定など
    driven_by(:rack_test) 
  end

  it "新規登録画面から正しく登録できること" do
    visit new_user_registration_path
    puts page.html

    # フォームへの入力
    fill_in "user_club_name", with: "RSpecクラブ"
    fill_in "user_email", with: "test@example.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_address", with: "大阪府大阪市"
    fill_in "user_phone_number", with: "0612345678"

    # 送信ボタンをクリック
    click_button "Sign up"

    # 成功時の検証（例：トップページに遷移し、成功メッセージが出る）
    expect(current_path).to eq root_path
    expect(page).to have_content "アカウント登録が完了しました"
    expect(page).to have_content "RSpecクラブ" # ログイン後の画面に名前が出ると仮定
  end

  it "入力漏れがある場合にエラーが表示されること" do
    visit new_user_registration_path
    
    # ここもidで指定
    fill_in "user_email", with: ""
    click_button "Sign up"

    expect(page).to have_content "Eメールを入力してください" # 日本語化している場合は文言に注意
  end
end