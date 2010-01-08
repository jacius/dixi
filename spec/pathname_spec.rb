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

end
