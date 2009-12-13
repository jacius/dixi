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


require 'grit'

module Dixi
  module Git
    class << self

      # Returns a Grit::Repo to the data repository, initializing the
      # repository on disk if it doesn't already exist.
      # 
      def repo
        @repo ||= Grit::Repo.new( Dixi.contents_dir.to_s )
      rescue Grit::InvalidGitRepositoryError
        new_repo
      end

      # Add the files to the index (staging area), to be committed
      # next time #commit is called. Used for both adding new files
      # and replacing the contents of an existing file.
      # 
      # paths is one or more absolute paths (as strings or Pathnames)
      # to files to add.
      # 
      def add( *paths )
        in_contents_dir do
          repo.git.add({}, *( paths.flatten.collect{|p| p.to_s} ) )
        end
      end

      # Commit all the changes that were added with #add.
      def commit( message )
        in_contents_dir do
          repo.commit_index(message)          
        end
      end

      private

      # chdir to the contents dir, run the block, then chdir back.
      def in_contents_dir(&block)
        pwd = Dir.pwd
        Dir.chdir repo.git.work_tree
        yield
        Dir.chdir pwd
      end

      # Init contents/.git and make first commit, then return the Repo.
      def new_repo
        # The Grit API is so disjointed. Blech!

        dotgitdir = Dixi.contents_dir.join(".git").to_s
        Grit::GitRuby::Repository.init(dotgitdir, false)

        # Now grab a Git::Repo object
        @repo = Grit::Repo.new( Dixi.contents_dir.to_s )

        # Set up the user config
        cfg = Grit::Config.new(@repo)
        cfg["user.name"] = "Dixi Server"
        cfg["user.email"] = "dixi@#{Dixi.host}"

        # First commit
        in_contents_dir do
          puts @repo.git.commit({}, "--allow-empty",
                                "-m", "Created repository.")
        end

        return @repo
      end

    end
  end
end
