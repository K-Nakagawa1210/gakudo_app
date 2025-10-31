bootstrap_path = Rails.root.join('node_modules', 'bootstrap', 'scss').to_s

if defined?(SassC)
  Rails.application.config.sassc.load_paths << bootstrap_path
end

Rails.application.config.assets.paths << bootstrap_path
