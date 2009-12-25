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
  class Project

    def initialize( name, version=:latest )
      @name = name
      @version = case version
                 when :latest
                   latest_version
                 else Dixi::Version.new(version)
                 end
      @host = "unknown"
    end

    attr_reader :name, :version
    attr_accessor :host

    def name_and_version
      @name + "/" + @version
    end

    def dir
      Dixi.contents_dir.join(@name)
    end

    def version_dir
      dir.join(@version.to_s)
    end

    def api
      @api ||= Dixi::API.new(self)
    end

    # Create a new Resource for this project
    def resource( entry )
      Dixi::Resource.make( :project => self, :entry => entry )
    end


    def url
      Dixi.url_base.join(@name)
    end

    def version_url
      url.join(@version.to_s)
    end


    # Return a different version of this project.
    def at_version( other_version )
      self.class.new(@name, other_version)
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


    # Add the files to the index (staging area), to be committed
    # next time #commit is called. Used for both adding new files
    # and replacing the contents of an existing file.
    # 
    # paths is one or more absolute paths (as strings or Pathnames)
    # to files to add.
    # 
    def git_add( *paths )
      Dir.chdir( dir ) do
        git_repo.git.add({}, *(paths.flatten.collect{|p| p.to_s}) )
      end
    end

    # Commit all the changes that were added with #add.
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
                         "-m", "Created repository for project \"#{@name}\".")
      end

      return @repo
    end

  end
end
