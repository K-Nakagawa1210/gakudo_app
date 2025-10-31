node_modules_path = Rails.root.join('node_modules').to_s

if defined?(SassC)
  Rails.application.config.sassc.load_paths << node_modules_path
end

Rails.application.config.assets.paths << node_modules_path