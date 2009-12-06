require_relative "../src/version"

Version = Dixi::Version

describe Version do

  VALID = {
    "0"                 => [0],
    "0.1"               => [0,1],
    "1"                 => [1],
    "1.0"               => [1,0],
    "23.4"              => [23,4],
    "05.67.8.90"        => [5,67,8,90],
    "1234567890"        => [1234567890],
    "1.23.456.78.9.000" => [1,23,456,78,9,0],
    "123".intern        => [123],
    "123.45".intern     => [123,45],
    4                   => [4],
    1.5                 => [1,5],
    [1,2,3]             => [1,2,3]
  }

  VALID.each do |ver_str,ver_ary|
    it "should successfully parse #{ver_str.inspect}" do
      Version.new(ver_str).parts.should be_eql( ver_ary )
    end
  end


  INVALID = ["-1", "1.b", "5 4 3 2 1", "1,2,3",
             "blue fish", ":)", :red_fish,
             [1,"fish"], {2 => "fish"} ]

  INVALID.each do |ver_str|
    it "should raise error for #{ver_str.inspect}" do
      proc{ Version.new(ver_str) }.should raise_error
    end
  end


  it "'1' should be equal to '1.0'" do
    Version.new("1").should == Version.new("1.0")
  end

  it "'1' should be greater than '0.9'" do
    Version.new("1").should > Version.new("0.9")
  end

  it "'1' should be greater than '0'" do
    Version.new("1").should > Version.new("0")
  end

  it "'1' should be less than '1.1'" do
    Version.new("1").should < Version.new("1.1")
  end

  it "'1' should be less than '2'" do
    Version.new("1").should < Version.new("2")
  end


  it "'1.0' should be equal to '1.0'" do
    Version.new("1.0").should == Version.new("1.0")
  end

  it "'1.1' should be greater than '1.0'" do
    Version.new("1.1").should > Version.new("1.0")
  end

  it "'1.0' should be less than '2.0'" do
    Version.new("1.0").should < Version.new("2.0")
  end


  it "should be comparable to strings" do
    (Version.new("1") <=> "1").should == 0
  end

  it "should be comparable to symbols" do
    (Version.new("1") <=> "1".intern).should == 0
  end

  it "should be comparable to integers" do
    (Version.new("1") <=> 1).should == 0
  end

  it "should be comparable to floats" do
    (Version.new("1") <=> 1.0).should == 0
  end


  it "should be comparable to arrays of ints" do
    (Version.new("1.0") <=> [1,0]).should == 0
  end

  it "should be comparable to arrays of a float" do
    (Version.new("1.0") <=> [1.0]).should == 0
  end

  it "should be comparable to arrays of strings" do
    (Version.new("1.0") <=> ["1","0"]).should == 0
  end


  INVALID.each do |thing|

    it "should raise error on <=> #{thing.inspect}" do
      proc{Version.new("1.0") <=> thing}.should raise_error(ArgumentError)
    end

    it "should not raise error on == #{thing.inspect}" do
      proc{Version.new("1.0") == thing}.should_not raise_error
    end

    it "should not == #{thing}" do
      Version.new("1.0").should_not == thing
    end

  end


  it "to_s should return a String" do
    Version.new("1.0").to_s.should be_instance_of(String)
  end

end
