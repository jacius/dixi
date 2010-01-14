
$LOAD_PATH.unshift ::File.join(::File.dirname(__FILE__), "vendor")


# Comment this out if you don't want rubygems:
require 'rubygems'


require 'dixi'

Dixi::App.configure do
  logfile = Dixi.main_dir.join("log","dixi.log")
  Dixi.logger.io = logfile.open("a")
  Dixi.logger.sync = true
  $stdout = $stderr = Dixi.logger
  use Rack::CommonLogger, $stdout
end

Dixi::App.configure :development do
  use Rack::ShowExceptions
end

run Dixi::App.new
