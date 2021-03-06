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
  class App

    helpers do

      # Checks the request URI for certain special cases where URI
      # syntax interferes with Ruby method syntax.
      #
      # Returns a URI that the user should be redirected to, or nil if
      # they should not be redirected.
      # 
      def check_for_redirect( request_uri )
        # If URI ends with ?, assume they meant a method that ends
        # with a question mark, which should have been %3F in the URI.
        if request_uri[-1..-1] == "?"
          return request_uri[0..-2]+"%3F"
        end

        # Or if there are two ??'s, assume the first one should be %3F.
        if request_uri =~ /\?\?/
          return request_uri.gsub("??","%3F?")
        end
      end


      def get_resource( project, id )
        project.matching(id).first or project.resource(id)
      end


    end


    before do
      other_page = check_for_redirect( env["REQUEST_URI"] )
      unless other_page.nil?
        redirect other_page, 302
      end
    end


    get '/' do
      Dixi::Views::Root.new.render
    end

    
    ########
    # YAML #
    ########

    get '/:project/:version/*.yaml' do
      @project = Project.new( params[:project], params[:version] )
      @resource = get_resource( @project, params[:splat][0] )

      content_type '.yaml', :charset => 'utf-8'

      if @resource.has_content?
        @resource.yaml_content
      else
        headers( "Cache-Control" => "private" )
        error 404
      end
    end


    put '/:project/:version/*.yaml' do
      @project = Project.new( params[:project], params[:version] )
      @project.host = request.host
      @resource = get_resource( @project, params[:splat][0] )
      is_new = !@resource.has_content?

      @resource.yaml_content = request.body.read
      @resource.save

      if is_new
        @project.git_commit( "Created #{request.path_info} as YAML" )
      else
        @project.git_commit( "Edited #{request.path_info} as YAML" )
      end

      @project.index.save

      headers["Location"] = @resource.url_read_yaml
      headers["Cache-Control"] = "private"
      content_type '.yaml', :charset => 'utf-8'
      status 201

      YAML.dump("message" => "Resource " + (is_new ? "created." : "updated."),
                "uri" => {
                  "yaml" => @resource.url_read_yaml,
                  "html" => @resource.url_read })
    end


    delete '/:project/:version/*.yaml' do
      @project = Project.new( params[:project], params[:version] )
      @project.host = request.host
      @resource = get_resource( @project, params[:splat][0] )

      @resource.delete
      @project.git_commit( "Deleted #{request.path_info}" )

      @project.index.save

      headers["Location"] = @resource.url_read_yaml
      headers["Cache-Control"] = "private"
      content_type '.yaml', :charset => 'utf-8'
      status 200

      YAML.dump("message" => "Resource deleted.",
                "uri" => {
                  "yaml" => @resource.url_read_yaml,
                  "html" => @resource.url_read })
    end



    ########
    # HTML #
    ########

    get '/:project/?' do
      @project = Project.new( params[:project], :latest )
      @resource = @project

      if params.has_key? "edit"
        @project.template_edit.render
      else
        @project.template_read.render
      end
    end


    put '/:project' do
      @project = Project.new( params[:project] )
      @project.host = request.host
      is_new = !@project.has_content?

      @project.yaml_content = request.POST["content"]
      @project.save

      if is_new
        @project.git_commit( "Created #{request.path_info}" )
      else
        @project.git_commit( "Edited #{request.path_info}" )
      end

      @project.index.save

      redirect @project.url_read
    end



    get '/:project/:version/?' do
      @project = Project.new( params[:project], params[:version] )
      Dixi::Views::ReadVersion.new( :project => @project ).render
    end


    get '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @resource = get_resource( @project, params[:splat][0] )

      # EDIT FORM
      if params.has_key? "edit"
        @resource.template_edit.render

      # CREATE FORM
      elsif params.has_key? "create"
        ivars = { :parent => @resource }

        # Check if submitting this form should overwrite the current
        # resources of the same name (if any). The view will inform
        # the user of the situation.
        ivars[:overwrite] = (true if params["overwrite"] =~ /y|yes|true/i)
        if ivars[:overwrite]
          ivars[:name]     = session[:overwrite_name]    || ""
          ivars[:content]  = session[:overwrite_content] || ""
          ivars[:existing] = @resource.child( ivars[:name] )

          # Clear the session
          session[:overwrite_name] = nil
          session[:overwrite_content] = nil
        end

        @resource.template_create( ivars ).render

      # DELETE FORM
      elsif params.has_key? "delete"
        @resource.template_delete.render

      # READ PAGE
      else
        if not @resource.has_content?
          headers( "Cache-Control" => "private" )
          status 404
        end
        @resource.template_read.render
      end
    end


    post '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @project.host = request.host
      @resource = get_resource( @project, params[:splat][0] )

      @resource = @parent.child( request.POST["name"] )
      @overwrite = (true if params["overwrite"] =~ /y|yes|true/i)
      
      if @resource.has_content? and not @overwrite
        # There is already a resource by this name. Redirect back to
        # the create form to ask the user if they really want to
        # overwrite it.
        session[:overwrite_name]    = request.POST["name"]
        session[:overwrite_content] = request.POST["content"]
        redirect @parent.url_create(:overwrite => true)

      else
        @resource.yaml_content = request.POST["content"]
        if request.POST["type"]
          @resource.content.merge!( "type" => request.POST["type"] )
        end
        @resource.save
        @project.git_commit( "Created /#{@resource.name}" )
        @project.index.save
        redirect @resource.url_read
      end
    end


    put '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @project.host = request.host
      @resource = get_resource( @project, params[:splat][0] )
      is_new = !@resource.has_content?

      @resource.yaml_content = request.POST["content"]
      if request.POST["type"]
        @resource.content.merge!( "type" => request.POST["type"] )
      end
      @resource.save

      if is_new
        @project.git_commit( "Created #{request.path_info}" )
      else
        @project.git_commit( "Edited #{request.path_info}" )
      end

      @project.index.save

      redirect @resource.url_read
    end


    delete '/:project/:version/*' do
      @project = Project.new( params[:project], params[:version] )
      @project.host = request.host
      @resource = get_resource( @project, params[:splat][0] )

      @resource.delete
      @project.git_commit( "Deleted #{request.path_info}" )

      @project.index.save

      redirect @resource.url_read
    end


  end
end
