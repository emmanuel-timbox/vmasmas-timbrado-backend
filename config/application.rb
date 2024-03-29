require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TimboxPay
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.enable_dependency_loading = true
    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/**/"]

    config.api_only = true

    # config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
    #   allow do
    #     origins 'http://localhost:4200'
    #     resource('*',
    #              :headers => :any,
    #              :methods => [:get, :post, :options, :put, :delete, :patch]
    #     )
    #   end
    # end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
