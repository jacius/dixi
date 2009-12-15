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
Mustache.raise_on_context_miss = true

autoload :Kramdown, 'kramdown'
autoload :Grit, 'grit'

$LOAD_PATH.unshift Pathname.new(__FILE__).expand_path.dirname.to_s

require 'src/uri'

module Dixi

  autoload :Project,  'src/project'
  autoload :Version,  'src/version'
  autoload :Resource, 'src/resource'
  autoload :Helpers,  'src/helpers'

  def self.contents_dir
    Pathname.new(__FILE__).expand_path.dirname.join("contents")
  end

  def self.url_base
    URI.parse("/")
  end

  def self.host
    @host or "unknown"
  end

  def self.host=(new_host)
    @host = new_host
  end


  class App < Sinatra::Base
    use Rack::MethodOverride

    register Mustache::Sinatra
    set :views, 'templates'
    set :mustaches, 'views'
    set :namespace, Dixi


    before do
      Dixi.host = request.host
    end


    get '/' do
      mustache :index
    end


    get '/:project/:version/*.yaml' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )

      content_type '.yaml', :charset => 'utf-8'

      if @resource.has_content?
        @resource.content_as_yaml
      else
        headers( "Cache-Control" => "private" )
        error 404
      end
    end


    get '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )

      if params.has_key? "edit"
        mustache @resource.template_edit
      else
        if not @resource.has_content?
          headers( "Cache-Control" => "private" )
          status 404
        end
        mustache @resource.template_read
      end
    end


    put '/:project/:version/*.yaml' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )
      is_new = !@resource.has_content?

      @resource.save( :content => request.body.read, :raw => true )

      if is_new
        @project.git_commit( "Created #{request.path_info} as YAML" )
      else
        @project.git_commit( "Edited #{request.path_info} as YAML" )
      end

      headers["Location"] = @resource.url_read_yaml
      headers["Cache-Control"] = "private"
      content_type '.yaml', :charset => 'utf-8'
      status 201

      YAML.dump("message" => "Resource " + (is_new ? "created." : "updated."),
                "uri" => {
                  "yaml" => @resource.url_read_yaml,
                  "html" => @resource.url_read })
    end


    put '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )
      is_new = !@resource.has_content?

      @resource.save( :content => request.POST["content"],
                      :raw => true )

      if is_new
        @project.git_commit( "Created #{request.path_info}" )
      else
        @project.git_commit( "Edited #{request.path_info}" )
      end

      redirect @resource.url_read
    end

  end
end
