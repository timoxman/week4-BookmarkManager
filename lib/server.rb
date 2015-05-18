require 'sinatra/base'

class BookmarkManagerWeb < Sinatra::Base
  get '/' do
    'Hello BookmarkManagerWeb!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
