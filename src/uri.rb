
# Monkeypatching the stdlib URI::Generic class. Whee!

require 'uri'

class URI::Generic

  def join( *args )
    s = self.to_s
    s.slice!(-1) if s.end_with?('/')
    URI.parse( args.unshift(s).join('/') )
  end

end
