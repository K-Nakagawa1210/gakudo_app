# sassc-railsがnode_modules内の依存関係（例: Bootstrap）を見つけられるように、
# アプリケーションが初期化された後にロードパスを設定する。
Rails.application.config.after_initialize do
  if defined?(SassC)
    Rails.application.config.sassc.load_paths << Rails.root.join('node_modules')
  end
end