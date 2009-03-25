require "lib/chainable"

describe "Chainable#merge_method" do

  it "should be able to merge \"simple\" methods" do
    Class.new do
      old_ancestors = ancestors
      define_method(:simple) { 100 + 100 }
      new.simple.should == 200
      merge_method(:simple) { super - 100 }
      new.simple.should == 100
      ancestors.should == old_ancestors
    end
  end

  it "should refuse merging methods, if the merge would cause harm" do
    forbidden = []
    forbidden << lambda do
      Class.new do
        define_method(:same_lvars) { x = 10 }
        merge_method(:same_lvars) { x = 5; super; puts x }
      end
    end
    forbidden << lambda do
      Class.new do
        define_method(:do_eval) { eval "x = 10" }
        merge_method(:do_eval) { x = 5; super; puts x }
      end
    end
    forbidden << lambda do
      Class.new do
        define_method(:args) { |x| x }
        merge_method(:args) { super }
      end
    end
    forbidden << lambda do
      Class.new do
        define_method(:args) { |x| x = 0 }
        merge_method(:args) { |x| x.to_s; super; puts x }
      end
    end
    forbidden << lambda do
      Class.new { merge_method(:i_dont_exist) { } }
    end
    forbidden << lambda do
      superclass = Class.new { define_method(:inherited_method) { } }
      Class.new(superclass) { merge_method(:inherited_method) { } }
    end
    forbidden.each { |block| block.should raise_error(ArgumentError) }
  end

end
