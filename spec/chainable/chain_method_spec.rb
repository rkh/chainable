require "lib/chainable"

describe Chainable do

  before :each do
    @a_class = Class.new do
      def foo
        :foo
      end
      def foo2
        foo.to_s.upcase
      end
      def to_i
        42
      end
      def inspect
        random
        super
      end
      define_method(:random) { @some_value ||= rand(1000) }
    end
    @an_instance = @a_class.new
    @original_results = @a_class.instance_methods(false).inject({}) do |h, m|
      h.merge m => @an_instance.send(m)
    end
  end

  it "should not change the behaviour of the original methods" do
    5.times do
      @original_results.each do |method_name, method_result|
        @a_class.class_eval { chain_method method_name }
        @an_instance.send(method_name).should == method_result
      end
    end
  end

  it "should work for core methods" do
    Array.class_eval { chain_method :join }
    ["hello", "world"].join(" ").should == "hello world"
    String.class_eval { chain_method(:inspect) { "%#{super}" } }
    "hello world".inspect.should == '%"hello world"'
  end

  it "should define a new method, when block given" do
    @a_class.class_eval do
      chain_method(:to_i) { super - 5 }
      chain_method(:foo2) { "foo2" }
    end
    @an_instance.to_i.should == @original_results["to_i"] - 5
    @an_instance.foo2.should == "foo2"
  end

  it "should allow redefining the method later" do
    @a_class.class_eval do
      chain_method :to_i
      def to_i
        super + 20
      end
    end
    @an_instance.to_i.should == @original_results["to_i"] + 20
  end

  it "should keep inheritance intact" do
    a_module = Module.new do
      define_method(:inspect) { "some inspect result" }
      define_method(:foo) { "not foo" }
    end
    @a_class.class_eval do
      include a_module
      chain_method(:foo) { super }
    end
    another_class = Class.new(@a_class) do
      define_method(:foo) { :bar }
      define_method(:inspect) { super }
    end
    another_instance = another_class.new
    @an_instance.inspect.should == "some inspect result"
    @an_instance.foo.should == @original_results["foo"]
    another_instance.inspect.should == "some inspect result"
    another_instance.foo.should == :bar
  end

end