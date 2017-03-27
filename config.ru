require 'bundler'
Bundler.require

# Setup Database
DataMapper::Logger.new($stdout, :debug)

file = File.expand_path('./config/database.yml')
options = YAML.load_file(file)

DataMapper.setup(:default, options['development'])

# Load all models

Dir['./app/models/*.rb'].each { |file| require file }

DataMapper.auto_upgrade!

# Load all controllers
require './app/controllers/application_controller'
Dir['./app/controllers/*.rb'].each { |file| require file }



# Use warden

use Rack::Session::Cookie, secret: "hkjhcklsdckldlc"

use Warden::Manager do |config|
  config.scope_defaults :default, strategies: [:password], action: 'unauthenticated'
  config.failure_app = AuthenticationController

  config.serialize_into_session { |user| user.id }
  config.serialize_from_session { |id| User.get(id) }
end

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['email'] && params['user']['password']
  end

  def authenticate!
    user = User.first(email: params['user']['email'])
    if user.nil?
      fail!("Email does not exists")
    elsif user.authenticate(params['user']['password'])
      success!(user)
      puts "authenticated"
    else
      fail!("Invalid email password combination")
    end
  end
end

Warden::Manager.before_failure do |env, options|
  env['REQUEST_METHOD'] = 'POST'
end

# routes
map('/'){ run WebsiteController }
map('/auth') {run AuthenticationController}
map('/users') {run UsersController}
map('/admin') {run AdminController}
