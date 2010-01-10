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


# Monkeypatching the stdlib URI::Generic class. Whee!

require 'uri'

class URI::Generic

  # Append the given string(s) to this URI, separated by "/", in
  # the simple and expected way. "mp" stands for "monkey patch".
  # 
  #   uri = URI.parse("http://github.com")
  #   uri.mp_join("jacius","dixi")
  #   # => URL:http://github.com/jacius/dixi
  # 
  #   # Works with a trailing slash, too:
  #   uri = URI.parse("http://github.com/")
  #   uri.mp_join("jacius","dixi")
  #   # => URL:http://github.com/jacius/dixi
  # 
  def mp_join( *strings )
    s = self.to_s
    s.slice!(-1) if s[-1] == ?/
    URI.parse( strings.unshift(s).join('/') )
  end
end


# And Pathname! I'm so evil!

require 'pathname'

class Pathname

  # Simply append a string to the Pathname. Nothing fancy.
  # Returns the new Pathname. "mp" stands for "monkey patch".
  # 
  #   p = Pathname.new("foo")
  #   p.mp_append("bar.txt")   # Pathname:foobar.txt
  # 
  def mp_append( str )
    self.class.new( to_s + str.to_s )
  end


  # Remove the file extension from the Pathname, if it has one.
  # Returns the new Pathname. "mp" stands for "monkey patch".
  # 
  #   p = Pathname.new("a.txt")
  #   p.mp_no_ext                  # Pathname:a
  # 
  #   p2 = Pathname.new("b")
  #   p2.mp_no_ext                 # Pathname:b
  # 
  def mp_no_ext
    if extname.empty?
      self
    else
      Pathname.new( to_s.sub(Regexp.new(extname+"$"), "") )
    end
  end

end
