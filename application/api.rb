Encoding.default_external = 'UTF-8'

$LOAD_PATH.unshift(File.expand_path('./application'))

# Include critical gems
require 'config/variables'

if %w(development test).include?(RACK_ENV)
  require 'pry'
  require 'awesome_print'
end

require 'bundler'
Bundler.setup :default, RACK_ENV
require 'roda'
require 'rack/indifferent'
require 'grape'
require 'grape/batch'
require 'nokogiri'
# Initialize the application so we can add all our components to it
class Api < Grape::API; end
class ApiSupport < Roda; end

# Include all config files
require 'config/mail'
require 'config/sequel'
require 'config/hanami'
require 'config/sidekiq'
require 'config/rack'
require 'config/grape'

# require some global libs
require 'lib/core_ext'
require 'lib/time_formats'
require 'lib/io'

# load active support helpers
require 'active_support'
require 'active_support/core_ext'

# require all models
Dir['./application/models/*.rb'].each { |rb| require rb }

Dir['./application/api_helpers/**/*.rb'].each { |rb| require rb }
class Api < Grape::API
  use ApiLogger

  version 'v1.0', using: :path
  content_type :json, 'application/json'
  default_format :json
  prefix :api
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    ret = { error_type: 'validation', errors: {} }
    e.each do |x, err|
      ret[:errors][x[0]] ||= []
      ret[:errors][x[0]] << err.message
    end
    error! ret, 400
  end

  helpers SharedParams
  helpers ApiResponse
  include Auth

  before do
    authenticate!
  end

  Dir['./application/api_entities/**/*.rb'].each { |rb| require rb }
  Dir['./application/api/**/*.rb'].each { |rb| require rb }

  add_swagger_documentation \
    mount_path: '/docs'
end

class ApiSupport < Roda
  use Bugsnag::Rack if defined?(Bugsnag)

  plugin :multi_route
  plugin :all_verbs
  plugin :mailer, content_type: 'text/html'
  plugin :render, views: 'application/views',
                  ext: 'html.erb'
  plugin :partials
  plugin :content_for

  route do |r|
    r.root do
      'Nothing Here'
    end

    if RACK_ENV == 'development'
      # Test interface to preview html templates like emails
      # /static?layout=mailer-layout&view=/application/views/mailers/invitations/new_rep
      r.get 'static' do
        view_path = r['view'].split('/').delete_if(&:empty?)
        template = view_path[-1]
        path = view_path.slice(0..-2).join('/')
        view(template, layout: r['layout'], views: path)
      end
    end

    r.multi_route
  end

  Dir['./application/mailers/**/*.rb'].each { |rb| require rb }
end
