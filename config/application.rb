require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ResponseTimes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.active_job.queue_adapter = :sidekiq
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.updownio = {
      token: 'c2ry',
    }
    config.hg = {
      key: '2ef65f36-c77e-4024-a895-d486fd7c11f2',
      destination: '3de08a3c.carbon.hostedgraphite.com',
      port: '2003'
    }

    config.old_samples_job = {
      max_age: 5
    }
    config.force_catch_up = {
      max_age: 1
    }
  end
end
