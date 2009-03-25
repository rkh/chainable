require "lib/chainable"

describe "Chainable#chain_method(..., :try_merge => true)" do

  before do
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
        @a_class.class_eval { chain_method method_name, :try_merge => true }
        @an_instance.send(method_name).should == method_result
      end
    end
  end

  it "should work for core methods" do
    String.class_eval do
      chain_method(:upcase, :try_merge => true) do |*x|
        return super if x.empty?
        x.first
      end
    end
    "foo".upcase("bar").should == "bar"
  end

  it "should define a new method, when block given" do
    @a_class.class_eval do
      chain_method(:to_i, :try_merge => true) { super - 5 }
      chain_method(:foo2, :try_merge => true) { "foo2" }
    end
    @an_instance.to_i.should == @original_results["to_i"] - 5
    @an_instance.foo2.should == "foo2"
  end

  it "should allow passing multiple method names" do
    @a_class.class_eval do
      chain_method(:foo, :to_i, :try_merge => true) { super.to_s }
    end
    @an_instance.foo.should == @original_results["foo"].to_s
    @an_instance.to_i.should == @original_results["to_i"].to_s
  end

  it "should merge, if possible" do
    old_ancestors = @a_class.ancestors
    @a_class.class_eval do
      chain_method(:to_i, :foo, :try_merge => true) { super.to_s }
    end
    @a_class.ancestors.should == old_ancestors
  end

end
