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
  def join( *args )
    s = self.to_s
    s.slice!(-1) if s[-1] == ?/
    URI.parse( args.unshift(s).join('/') )
  end
end


# And Pathname! I'm so evil!

require 'pathname'

class Pathname

  # Simply append a string to the Pathname. Nothing fancy.
  # "mp" stands for "monkey patch".
  # 
  #   p = Pathname.new("foo")
  #   p.mp_append("bar.txt")   # Pathname:foobar.txt
  # 
  def mp_append( str )
    self.class.new( to_s + str.to_s )
  end

end
