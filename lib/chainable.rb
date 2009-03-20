require "ruby2ruby"

module Chainable

  def self.skip_chain
    return if @auto_chain
    @auto_chain = true
    yield
    @auto_chain = false
  end

  # This will "chain" a method (read: push it to a module and include it).
  # If a block is given, it will do a define_method(name, &block).
  # Maybe that is not what you want, as methods defined by def tend to be
  # faster. If that is the case, simply don't pass the block and call def
  # after chain_method instead.
  def chain_method(name, &block)
    name = name.to_s
    if instance_methods(false).include? name
      begin
        code = Ruby2Ruby.translate self, name
        include Module.new { eval code }
      rescue NameError
        m = instance_method name
        include Module.new { define_method(name) { |*a, &b| m.bind(self).call(*a, &b) } }
      end
    end
    block ||= Proc.new { super }
    define_method(name, &block)
  end

  # If you define a method inside a block passed to auto_chain, chain_method
  # will be called on that method right after it has been defined. This will
  # only affect methods defined for the class (or module) auto_chain has been
  # send to. See README.rdoc or spec/chainable/auto_chain_spec.rb for examples.
  def auto_chain
    class << self
      chain_method :method_added do |name|
        Chainable.skip_chain { chain_method name }
      end
    end
    result = yield
    class << self
      remove_method :method_added
    end
    result
  end
    
end

Module.class_eval do
  include Chainable
end
