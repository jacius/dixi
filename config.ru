
# Comment this out if you don't want rubygems:
require 'rubygems'


require 'dixi'

Dixi::App.configure :development do
  use Rack::ShowExceptions
  Mustache.raise_on_context_miss = true
end

Dixi::App.configure do
  $stdout = $stderr = Dixi::Log
  use Rack::CommonLogger, $stdout
end

run Dixi::App.new
