require 'sinatra/base'
require 'data_mapper'
require 'rack-flash'
require 'byebug'


class BookmarkManagerWeb < Sinatra::Base

  enable :sessions
  use Rack::Flash

  #line below allows you to encypt a cookie
  set :session_secret, 'super secret'

  #This will allow us to use a new method in our server file, 'delete'
  use Rack::MethodOverride

  #tells you where your views are..
  set :views, Proc.new { File.join(root, "", "views") }

  env = ENV['RACK_ENV'] || 'development'
  # we're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" or "bookmark_manager_development" depending on the environment
  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

  require './lib/link' # this needs to be done after datamapper is initialised
  require './lib/tag'
  require './lib/user'
  # require_relative 'helpers.rb'

  # After declaring your models, you should finalise them
  DataMapper.finalize

  # However, the database tables don't exist yet. Let's tell datamapper to create them
  # DataMapper.auto_upgrade! - moved to rakefile and manual on command line


  get '/' do
    p session
    @links = Link.all
    erb :index
  end

  post '/links' do
    url = params['url']
    title = params['title']
    tags = params['tags'].split(' ').map do |tag|
      # this will either find this tag or create
      # it if it doesn't exist already
      Tag.first_or_create(text: tag)
    end
    Link.create(url: url, title: title, tags: tags)
    redirect to('/')
  end

  get '/tags/:text' do
    tag = Tag.first(text: params[:text])
    @links = tag ? tag.links : []
    erb :index
  end

  get '/users/new' do
    # note the view is in views/users/new.erb
    # we need the quotes because otherwise
    # ruby would divide the symbol :users by the
    # variable new (which makes no sense)
    @user = User.new # only created to store stuff on screen
    erb :'users/new'
  end

  post '/users' do
    # we just initialize the object
    # without saving it. It may be invalid
    @user = User.new(email: params[:email],
                    password: params[:password],
                    password_confirmation: params[:password_confirmation])
    # let's try saving it
    # if the model is valid,
    # it will be saved  (user.save returns true if it works)
    if @user.save
      session[:user_id] = @user.id
      redirect to('/')
      # if it's not valid,
      # we'll show the same
      # form again
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    email, password = params[:email], params[:password]
    user = User.authenticate(email, password)
    if user
      session[:user_id] = user.id
      redirect to('/')
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    flash.now[:errors] = ["You've just logged out"]
    session[:user_id] = nil
    redirect to('/')
  end


  helpers do
    #let's create a helper that will give us access to the current user, if logged in - part of sinatra
    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end

  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end
