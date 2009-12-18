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


module Dixi

  # Dixi logging system. You can add your own messages to the log with
  # the #add method, or more conveniently with #debug, #info, #warn,
  # #error, and #fatal methods.
  # 
  #   logger = Dixi::Logger.new
  #   logger.error "Something broke!"
  # 
  # You can also assign it to $stdout or $stderr and/or use it with
  # Rack::CommonLogger.
  # 
  #   logger = Dixi::Logger.new
  #   $stdout = $stderr = logger
  #   use Rack::CommonLogger, logger
  # 
  # By default, the log is written to $stdout. You can change that by
  # setting #io= to an IO (such as an open File) of your choice.
  # 
  # By default, the output looks like this:
  # 
  #   [17/Dec/2009 15:53:18] (Dixi)  ERROR: Something broke!
  # 
  # You can change the date/time format by setting #time_format= to a
  # strftime-style string.
  # 
  # By default, messages with severity of :warn or higher (i.e. :error
  # and :fatal) are logged. You can change that with #level=, check it
  # with #level, or see if a specific message type would be logged
  # with #debug?, #info?, #warn?, #error?, and #fatal?
  # 
  class Logger

    require 'forwardable'
    extend Forwardable

    # Delegate these methods to @io
    def_delegators( :@io, :<<, :write, :flush, :sync, :sync= )


    # Severity levels.
    LEVELS = Hash.new{ |h,level|
      level = level.to_s.downcase.intern
      if h.has_key? level
        h[level]
      else
        raise ArgumentError, "Unknown log severity level #{level.inspect}."
      end
    }

    LEVELS.merge!( :debug => 0,
                   :info  => 1,
                   :warn  => 2,
                   :error => 3,
                   :fatal => 4 )


    def initialize( io=$stdout, level=:warn )
      @io    = io    || $stdout
      @level = level || :warn
      @time_format = "%d/%b/%Y %T"
    end

    attr_accessor :io, :level, :time_format


    # Add a message to the log with nice formatting, if the severity
    # high enough (or if severity is nil).
    #
    # severity:: The severity of the message: :debug, :info, :warn,
    #            :error, or :fatal. Or nil to bypass the severity
    #            level (i.e. always add the message). Default: nil.
    #
    # Returns true if the message was added to the log, or false if it
    # was not added (because the message severity was too low).
    # 
    def add( message, severity=nil )
      if severe_enough?( severity )
        @io << format_message( message, severity )
        true
      else
        false
      end
    end

    alias :puts :add


    # Nicely formats the message and returns the resulting string.
    def format_message( message, severity=@level, time=Time.now )
      severity = (severity.nil?) ? ("") : (severity.to_s.upcase + ": ")

      "[%s] (Dixi)  %s%s\n"%[ time.strftime(@time_format),
                              severity,
                              message.to_s ]
    end


    # Define #debug, #debug?, #info, #info?, etc.
    LEVELS.keys.each do |level|

      define_method( level ) do |message|
        add( message, level )
      end

      define_method( "#{level}?" ) do
        severe_enough?( level )
      end

    end


    private

    def severe_enough?( severity )
      severity.nil? or (LEVELS[severity] >= LEVELS[@level])
    end

  end
end
