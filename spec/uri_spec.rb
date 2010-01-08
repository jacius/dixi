require 'pathname'
$LOAD_PATH.unshift Pathname.new(__FILE__).expand_path.dirname.parent.to_s

require "src/monkeypatch"


describe URI do

  it "should have a join method" do
    URI.parse("http://github.com").should respond_to(:join)
  end

  it "join should make another URI" do
    uri = URI.parse("http://github.com").join("jacius")
    uri.should be_instance_of URI::HTTP
  end

  it "should join all items, separated by slashes" do
    expected = "http://github.com/jacius/dixi"
    result = URI.parse("http://github.com").join("jacius","dixi").to_s
    result.should == expected
  end

  it "shouldn't have two slashes after the host" do
    expected = "http://github.com/jacius/dixi"
    result = URI.parse("http://github.com/").join("jacius","dixi").to_s
    result.should == expected
  end

end
