#
#  Copyright 2009 John Croisant
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  


require 'forwardable'
require 'logger'

module Dixi
  module Log
    class << self
      extend Forwardable

      def setup
        @logfile = Dixi.main_dir.join("log", "dixi.log")

        @levels = {
          :debug => Logger::DEBUG,
          :info  => Logger::INFO,
          :warn  => Logger::WARN,
          :error => Logger::ERROR,
          :fatal => Logger::FATAL,
        }
        @level = :warn

        make_logger

        nil
      end


      def make_logger
        @logger.close() rescue NoMethodError
        @logger = ::Logger.new( @logfile.to_s )
        @logger.progname = "Dixi"
        @logger.datetime_format = "%d/%b/%Y %T "
        self.level = @level
      end


      attr_reader :logfile

      def logfile=( path )
        @logfile = path
        make_logger

        @logfile
      end

      def write( s )
        @logger << s
      end

      alias :<< :write

      def_delegators( :@logger,
                      :debug, :debug?,
                      :info,  :info?,
                      :warn,  :warn?,
                      :error, :error?,
                      :fatal, :fatal? )

      attr_reader :level

      def level=( level_symbol )
        unless @levels.has_key?( level_symbol )
          raise ArgumentError, "Invalid log level #{level_symbol.inspect}"
        end
        @level = level_symbol
        @logger.level = @levels[@level]
      end

    end
  end
end


Dixi::Log.setup
