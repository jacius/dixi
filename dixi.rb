#!/bin/env ruby

require 'sinatra/base'
require 'mustache/sinatra'
require 'pathname'

require_relative 'src/git'
require_relative 'src/uri'
require_relative 'src/helpers'
require_relative 'src/project'


Mustache.raise_on_context_miss = true


module Dixi

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

    get '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )

      if params.has_key? "edit"
        mustache :edit_resource
      else
        mustache :read_resource
      end
    end

    put '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @resource = @project.resource( params[:splat][0] )

      is_new = !@resource.has_content?

      @resource.save( request.POST["content"], :raw => true )

      if is_new
        Dixi::Git.commit( "Created #{request.path_info}" )
      else
        Dixi::Git.commit( "Edited #{request.path_info}" )
      end

      redirect @resource.url_read
    end

  end
end
