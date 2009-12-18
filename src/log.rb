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

  # Dixi logging system. This module can be assigned to $stdout or
  # $stderr and used with Rack::CommonLogger. You can also add
  # messages with the #debug, #info, #warn, #error, and #fatal methods.
  # 
  #   Dixi::Log.error "Something broke!"
  # 
  # By default, the log is written to "dixi/log/dixi.log" (dixi is the
  # top dixi directory). You can change the log file with logfile=.
  # 
  # By default the output looks like this:
  # 
  #   [17/Dec/2009 15:53:18] (Dixi) ERROR: Something broke!
  # 
  # You can change the date/time format by setting #datetime_format=.
  # It accepts a strftime-formatted string.
  # 
  # By default, messages with severity of :warn or higher (i.e. :error
  # and :fatal) are logged. You can change that with #level=, check it
  # with #level, or see if a specific message type would be logged
  # with #debug?, #info?, #warn?, #error?, and #fatal?
  # 
  module Log

    # Custom log formatter for the Logger. Output looks like this:
    # 
    #   [17/Dec/2009 15:53:18] (Dixi) ERROR: Something broke!
    # 
    class Formatter
      def initialize
        # Apache style by default.
        @datetime_format = "%d/%b/%Y %T"
      end

      attr_accessor :datetime_format

      def call( severity, time, progname, msg )
        time = time.strftime(@datetime_format)
        "[%s] (%s) %s: %s\n"%[time, progname, severity, msg.to_s]
      end
    end


    class << self
      extend Forwardable

      # Initial setup of the logging system. This is called
      # automatically at the bottom of this file.
      def setup                 # :nodoc:
        # Save this for later
        @stdout = $stdout

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
      end

      # (Re)Create the @logger. Used at initialization and whenever
      # the logfile changes.
      def make_logger           # :nodoc:
        @logger.close() rescue NoMethodError
        @logger = Logger.new( @logfile.to_s )
        @logger.progname = "Dixi"
        @logger.formatter = Dixi::Log::Formatter.new()
        self.level = @level
      end
      private :make_logger


      attr_reader :logfile

      # Set the file path that log messages are written to. path
      # should be an absolute Pathname or string.
      def logfile=( path )
        @logfile = path
        make_logger # Remake the logger with the new path
      end


      # Write a string to the log. You can also use the debug, info,
      # warn, error, or fatal methods.
      def write( s )
        @logger << s
      end

      alias :<< :write


      def flush
        # noop
      end


      attr_reader :level

      # Set the log level. Unlike normal Logger, this takes a symbol
      # (:debug, :info, :warn, :error, or :fatal).
      def level=( level_symbol )
        unless @levels.has_key?( level_symbol )
          raise ArgumentError, "Invalid log level #{level_symbol.inspect}"
        end
        @level = level_symbol
        @logger.level = @levels[@level]
      end


      # These methods are delegated to @logger.
      def_delegators( :@logger,
                      :debug, :debug?,
                      :info,  :info?,
                      :warn,  :warn?,
                      :error, :error?,
                      :fatal, :fatal? )

      def datetime_format
        @logger.formatter.datetime_format
      end

      def datetime_format=( fmt )
        @logger.formatter.datetime_format = fmt
      end

    end
  end
end


Dixi::Log.setup
