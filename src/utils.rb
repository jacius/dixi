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
  module Utils

    # Return a hash of directory contents, recursively.
    # 
    # Given a directory structure like this:
    # 
    # * a/
    #   * b.txt
    #   * c/
    #     * d.txt
    #     * e/
    # 
    # `ls_r( Pathname.new("a") )` will produce:
    # 
    #   { #<Pathname:a> => {
    #       #<Pathname:a/b.txt> => nil,
    #       #<Pathname:a/c> => {
    #         #<Pathname:a/c/d.txt> => nil,
    #         #<Pathname:a/c/e> => {}
    #       }
    #     }
    #   }
    # 
    # The path arg must be an instance of Pathname.
    # 
    # If a block is given, each Pathname will be passed to the block
    # and the result used in the hash instead of the Pathname. This
    # way, you can process the results as they are built, so you get a
    # hash of things besides Pathnames.
    # 
    # Symlinks are not followed.
    # 
    def ls_r( path, &block )
      new_path = path

      if block_given?
        new_path = block.call(path)
        return {} if new_path.nil?
      end

      children = nil

      if path.directory?
        # Call this method on each child. Makes an array of hashes.
        children = path.children.collect{ |child|
          ls_r( child, &block )
        }
        # Combine the array of hashes into a single hash.
        # But ignore any children that are nil.
        children = children.reduce({}){ |mem,child_hash|
          mem.merge!( child_hash.reject{ |k,v| k.nil? } )
          mem
        }
      end

      { new_path => children }
    end


    # Nicely truncate some text, trying to find a natural breaking
    # point. max_chars is the maximum string length to return.
    # 
    # Truncates at (in order of preference):
    # 
    # 1. The first paragraph break (two newlines) before the limit.
    # 2. The last end of sentence (".", "?", or "!") before the limit.
    # 3. The last end of clause (",", ";", or ":"]) before the limit.
    # 4. The last whitespace character before the limit.
    # 5. Or, the max_chars limit.
    # 
    def snip( text, max_chars=300 )
      short = text.slice(0, max_chars)

      # Truncate after the first paragraph break, if there is one.
      para = short.index(/\n\s*\n/m)
      return short[0,para] if para

      # Find the last end of sentence, end of clause, or space.
      sentence = short.rindex(/[.?!](\s|$)/)+1 rescue 0
      clause   = short.rindex(/[,;:](\s|$)/)+1 rescue 0
      space    = short.rindex(/\s/)            || 0

      # A position greater than this counts as "near the end".
      near_end = (short.length * 0.7).to_i
      half     = (short.length * 0.5).to_i

      # Somewhat fuzzy rules for finding a "natural breaking point" in
      # the text. Ideally a sentence end, clause end, or word break
      # near the end of the text. Otherwise, one after halfway.
      point = if    sentence >= near_end;   sentence
              elsif clause   >= near_end;   clause
              elsif space    >= near_end;   space
              elsif sentence >= half;       sentence
              elsif clause   >= half;       clause
              elsif space    >= half;       space
              end

      # If no break point was found, just return it all.
      return short unless point

      short[0,point].chomp
    end


  end
end

# You can do either Dixi::Utils.ls_r or include the module and do ls_r.
Dixi::Utils.extend( Dixi::Utils )
