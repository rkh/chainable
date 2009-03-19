require "ruby2ruby"

module Chainable

  def self.skip_chain
    return if @auto_chain
    @auto_chain = true
    yield
    @auto_chain = false
  end

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

  def auto_chain &block
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
