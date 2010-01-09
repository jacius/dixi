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
  class Project < Resource

    def initialize( dirname, version=:latest )
      @dirname = dirname
      @version = case version
                 when :latest
                   latest_version
                 else Dixi::Version.new(version)
                 end
      @host = "unknown"
      @project = self
      @content     = nil
      @yaml_content = nil
    end

    attr_reader :dirname, :version
    attr_accessor :host


    def name
      content["name"] || @dirname || ""
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end


    def dirname_and_version
      @dirname + "/" + @version
    end

    def dir
      Dixi.contents_dir.join(@dirname)
    end

    def version_dir
      dir.join(@version.to_s)
    end

    def filepath
      # e.g. "/rubygame/project.yaml"
      dir.join("project.yaml")
    end


    def api
      @api ||= Dixi::API.new(self)
    end

    # Create a new Resource for this project
    def resource( id )
      Dixi::Resource.make( :project => self, :id => id )
    end

    def matching( id )
      Dixi::Resource.matching( self, id )
    end


    def url( extra="" )
      Dixi.url_base.mp_join(@dirname).to_s + extra
    end

    def version_url
      Dixi.url_base.mp_join(@dirname, @version.to_s)
    end


    # Return a different version of this project.
    def at_version( other_version )
      self.class.new(@dirname, other_version)
    end

    def all_versions
      dir.children.collect { |child|
        begin
          Dixi::Version.new( child.basename ) 
        rescue ArgumentError
          nil
        end
      }.compact.sort
    end

    def latest_version
      all_versions[-1]
    end


    def template_read
      :read_project
    end


    # Add the files to the index (staging area), to be committed
    # next time #commit is called. Used for both adding new files
    # and replacing the contents of an existing file.
    # 
    # paths is one or more absolute paths (as strings or Pathnames)
    # to files to add.
    # 
    def git_add( *paths )
      Dir.chdir( dir ) do
        git_repo.add( *(paths.flatten.collect{|p| p.to_s}) )
      end
    end

    # Remove the files to the index (staging area), to be committed
    # next time #commit is called.
    # 
    # paths is one or more absolute paths (as strings or Pathnames)
    # to files to remove.
    # 
    def git_remove( *paths )
      Dir.chdir( dir ) do
        git_repo.remove( *(paths.flatten.collect{|p| p.to_s}) )
      end
    end

    # Commit all the changes that were staged with #git_add or
    # #git_remove.
    def git_commit( message )
      Dir.chdir( dir ) do
        git_repo.commit_index(message)          
      end
    end


    private


    # Returns a Grit::Repo to the data repository, initializing the
    # repository on disk if it doesn't already exist.
    # 
    def git_repo
      require 'grit'
      @repo ||= Grit::Repo.new( dir.to_s )
    rescue Grit::InvalidGitRepositoryError
      new_git_repo
    end


    # Init repo and make first commit, then return a Grit::Repo instance.
    def new_git_repo
      # Init the repo as a bare repo (because Grit::Repo can't init
      # non-bare repos yet), then make it non-bare.
      @repo = Grit::Repo.init_bare( dir.join(".git").to_s )
      @repo.config["core.bare"] = "false"
      @repo.config["core.logallrefupdates"]  = "true"

      # Set up the committer for commits made on the server.
      @repo.config["user.name"]  = "Dixi Server"
      @repo.config["user.email"] = "dixi@#{@host}"

      # First commit
      Dir.chdir( dir ) do
        @repo.git.commit({}, "--allow-empty",
                         "-m", "Created repository for project \"#{@dirname}\".")
      end

      return @repo
    end

  end
end
