require "lib/chainable"

describe Chainable do

  it "should chain all methods defined inside auto_chain" do
    a_class = Class.new do
      auto_chain do
        define_method(:foo) { 100 }
        define_method(:foo) { super * 2 }
        define_method(:foo) { super + 22 }
      end
    end
    a_class.new.foo.should == 222
  end

  it "should allow defining methods both inside and outside of auto_chain" do
    a_class = Class.new do
      define_method(:foo) { 100 }
      chain_method :foo
      auto_chain { define_method(:foo) { super * 2 } }
      define_method(:foo) { super + 22 }
    end
    a_class.new.foo.should == 222
  end

  it "should allow auto_chain with core functions" do
    # We screw with String#reverse, this could mess up other specs.
    String.class_eval do
      chain_method :reverse # or we would overwrite the original
      auto_chain do
        define_method(:reverse) { super * 2 }
        define_method(:reverse) { super.downcase }
      end
    end
    "Test".reverse.should == "tsettset"
  end

end