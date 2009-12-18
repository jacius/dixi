
# Comment this out if you don't want rubygems:
require 'rubygems'


require 'dixi'

Dixi::App.configure do
  logfile = Dixi.main_dir.join("log","dixi.log")
  Dixi.logger.io = logfile.open("a")
  $stdout = $stderr = Dixi.logger
  use Rack::CommonLogger, $stdout
end

Dixi::App.configure :development do
  Dixi.logger.sync = true
  use Rack::ShowExceptions
  Mustache.raise_on_context_miss = true
end

run Dixi::App.new
