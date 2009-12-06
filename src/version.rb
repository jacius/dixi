
module Dixi
  class Version < String

    def initialize( ver )
      case ver
      when self.class
        @parts = ver.parts.dup
      when Array
        @parts = parse( ver.join(".") )
      else
        @parts = parse( ver.to_s )
      end
      super( ver.to_s )
    end


    attr_reader :parts


    # Override String's method
    def ==( other )
      (self <=> other) == 0
    rescue
      false
    end


    def <=>( other )
      begin
        oparts = self.class.new(other).parts
      rescue ArgumentError
        raise ArgumentError, "cannot compare Version with #{other.inspect}"
      end

      diff = @parts.length - oparts.length

      if diff < 0
        # pad @parts with 0's to get same length as oparts, then compare
        (@parts + Array.new(-diff,0)) <=> oparts
      elsif diff > 0
        # pad oparts with 0's to get same length as @parts, then compare
        @parts <=> (oparts + Array.new(-diff,0))
      else
        # same number of parts, don't pad either
        @parts <=> oparts
      end
    end


    def inspect
      "#<Version #{to_s}>"
    end

    def to_s
      String.new(self)
    end


    private


    def parse( str )
      # Matches e.g. "1", "0.1", "100.20.3.45"
      valid_re = /^([0-9]+(?:\.[0-9]+)*)$/

      matches = valid_re.match( str )
      if matches.nil?
        raise ArgumentError, "Invalid version: #{str.inspect}"
      end
      matches[1].split(".").collect{|n| n.to_i}
    end

  end
end
