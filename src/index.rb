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

require 'enumerator'

module Dixi

  # Index (table of contents) for project resources.
  class Index
    include Enumerable

    def initialize( project )
      @project  = project
      @entries  = nil
      @modified = false
      @loaded   = false
    end

    attr_reader :project


    # True if the index file exists and is readable.
    def exist?
      filepath.file? and filepath.readable?
    end

    # True if the index has been loaded from disk (or generated).
    def loaded?
      @loaded
    end


    # True if the index has no ids in it (even after being loaded).
    def empty?
      entries.empty?
    end

    # Returns the ids of all entries in the index.
    def keys
      entries.keys
    end

    # Returns the number of entries in the index.
    def size
      entries.size
    end
    alias :length :size


    # Iterate over each entry, yielding an Index::Entry to the block.
    def each( &block )
      if block_given?
        entries.each{ |id,entry| yield Entry.new(self,id,entry) }
      else
        Enumerator.new(self, :each)
      end
    end


    # Returns an Index::Entry for the given id, or nil if there's no
    # entry in the index with that id.
    def []( id )
      entry = entries[id]
      Entry.new( self, id, entry ) if entry
    end

    # Set an index entry. entry can be an Index::Entry or a Hash of
    # contents for the entry.
    def []=( id, entry )
      entries[id] = case entry
                    when Entry; entry.content
                    when Hash;  entry
                    else
                      raise "Invalid entry: #{entry.inspect}"
                    end
      mark_modified
    end


    # Adds (or updates) a resource to the index.
    def add( resource )
      entries.merge!( resource.index_dump )
      mark_modified
    end

    # Delete the index entry with the given id, if it exists.
    def delete( id )
      entry = entries.delete(id)
      if entry
        mark_modified
        Entry.new(self, id, entry)
      end
    end


    # Mark the index as being modified, so it will be saved.
    def mark_modified
      @modified = true
      nil
    end

    # True if #mark_modified has been called (unless #clear_modified
    # has also been called).
    def modified?
      @modified
    end

    # Undoes the effect of #mark_modified.
    def clear_modified
      @modified = false
      nil
    end


    # If the index has been #mark_modified, save the index to disk and
    # #clear_modified. Does not save if the index is empty.
    # 
    def save
      if modified? and @entries and !@entries.empty?
        save!
      end
    end

    # Like #save, but saves even if the index is empty or hasn't been
    # modified.
    # 
    def save!
      filepath.dirname.mkpath
      filepath.open( "w" ) do |f|
        f << YAML.dump( @entries )
      end
      clear_modified
      true
    end


    # Generate a new index by scanning all the files in the project.
    # This can take a long time (many seconds) for projects with many
    # entries, so it should not be done lightly.
    # 
    # The index will be saved to disk immediately after being generated.
    # 
    def generate
      Dixi.logger.info "Generating index for #{@project}"

      @entries = {}

      require 'find'
      Find.find( @project.version_dir.to_s ) do |path|
        if path =~ /index\.yaml/
          Find.prune
        elsif path =~ /\.yaml/
          res = Dixi::Resource.from_filepath(@project, Pathname.new(path))
          self.add( res )
        end
      end

      save!
      @loaded = true

      @entries
    end


    private

    def entries
      @entries ||= load
    end

    def filepath
      @project.version_dir.mp_join("index.yaml")
    end

    def load
      @entries = YAML.load_file( filepath ) || {}
    rescue Errno::ENOENT
      generate()
    ensure
      @loaded = true
    end

  end


  class Index::Entry

    def initialize( index, id, content )
      @index   = index
      @id      = id
      @content = content
    end

    attr_reader :id, :content

    def inspect
      "#<#{self.class} #{@id.inspect}>"
    end

    def []( key )
      @content[key]
    end

    def []=( key, value )
      @content[key] = value
      index[@id] = @content
    end

    # Return a Resource for this entry
    def resource
      @index.project.resource( @id )
    end


    def children
      @index.find_all{ |entry|
        entry.id =~ /^#{id_no_suffix}\/[^\/]+$/
      }
    end


    private

    def id_no_suffix
      Resource::OPT_SUFFIX_REGEXP.match(@id)[1]
    end

  end

end
