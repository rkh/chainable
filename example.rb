$: << "./lib"
require "chainable"

class Foo
  auto_chain do
  
    def foo
      10
    end
    
    def foo
      super + 1
    end
    
    def foo
      super ** 2
    end
    
  end
end

puts Foo.new.foo # => 121