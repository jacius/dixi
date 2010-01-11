require 'pathname'
$LOAD_PATH.unshift Pathname.new(__FILE__).expand_path.dirname.parent.to_s

require "src/monkeypatch"


describe Pathname do

  it "should have an mp_append method" do
    Pathname.new("foo").should respond_to(:mp_append)
  end

  it "mp_append should make another Pathname" do
    path = Pathname.new("foo").mp_append("bar.txt")
    path.should be_instance_of Pathname
  end

  it "mp_append should append the string to the path" do
    path = Pathname.new("foo").mp_append("bar.txt")
    path.should == Pathname.new("foobar.txt")
  end



  describe "mp_join" do

    it "should take any number of arguments" do
      lambda{ Pathname.new("a").mp_join          }.should_not raise_error
      lambda{ Pathname.new("a").mp_join("b")     }.should_not raise_error
      lambda{ Pathname.new("a").mp_join("b","c") }.should_not raise_error
    end

    it "should return a Pathname" do
      Pathname.new("a").mp_join("b").should be_instance_of( Pathname )
    end

    it "should join the args like File.join does" do
      result = Pathname.new("a").mp_join("b","c")
      result.to_s.should == File.join("a","b","c")
    end

    it "should return an equivalent pathname if given no args" do
      Pathname.new("a").mp_join.should == Pathname.new("a")
    end

    BAD_ARGS = [nil, 0, {}, Object.new]

    BAD_ARGS.each do |arg|
      it "should raise TypeError if given #{arg.inspect}" do
        lambda{
          Pathname.new("a").mp_join(arg)
        }.should raise_error(TypeError)
      end
    end

  end



  describe "mp_no_ext" do

    it "should take exactly zero args" do
      lambda{ Pathname.new("foo").mp_no_ext     }.should_not raise_error
      lambda{ Pathname.new("foo").mp_no_ext("") }.should raise_error
    end

    it "should return a Pathname" do
      Pathname.new("foo").mp_no_ext.should be_instance_of( Pathname )
    end

    it "should remove the filename extension" do
      Pathname.new("foo.txt").mp_no_ext.should == Pathname.new("foo")
    end

    it "should do nothing if there is no filename extension" do
      Pathname.new("foo").mp_no_ext.should == Pathname.new("foo")
    end

  end

end
