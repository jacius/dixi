
# Comment this out if you don't want rubygems:
require 'rubygems'


require 'dixi'

Dixi::App.configure :development do
  use Rack::ShowExceptions
  Mustache.raise_on_context_miss = true
end

run Dixi::App.new
