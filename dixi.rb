#!/bin/env ruby

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

require 'pathname'
require 'sinatra/base'
require 'mustache/sinatra'

$LOAD_PATH.unshift Pathname.new(__FILE__).expand_path.dirname.to_s

require 'src/uri'

autoload :YAML, 'yaml'

module Dixi

  autoload :Project,  'src/project'
  autoload :Version,  'src/version'
  autoload :API,      'src/api'
  autoload :Resource, 'src/resource'
  autoload :Helpers,  'src/helpers'
  autoload :Logger,   'src/logger'
  autoload :Utils,    'src/utils'


  def self.logger
    @logger ||= Dixi::Logger.new
  end

  def self.main_dir
    @main_dir ||= Pathname.new(__FILE__).expand_path.dirname
  end

  def self.contents_dir
    @contents_dir ||= begin
                        d = main_dir.join("contents")
                        if d.symlink?; d.readlink else d end
                      end
  end

  def self.url_base
    URI.parse("/")
  end


  class App < Sinatra::Base
    use Rack::MethodOverride

    register Mustache::Sinatra
    set :views, 'templates'
    set :mustaches, 'views'
    set :namespace, Dixi

    enable :sessions
  end


  require 'src/routes'

end
