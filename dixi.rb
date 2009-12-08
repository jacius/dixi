#!/bin/env ruby

require 'sinatra/base'
require 'mustache/sinatra'
require 'pathname'

require_relative 'src/uri'
require_relative 'src/helpers'
require_relative 'src/project'


Mustache.raise_on_context_miss = true


module Dixi

  def self.data_dir
    Pathname.new(__FILE__).expand_path.dirname.join("data")
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
      @resource.save_raw( request.POST["content"] )
      redirect @resource.url_read
    end

  end
end
