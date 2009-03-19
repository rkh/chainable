begin
  require "ruby2ruby"
rescue LoadError
end

module Chainable

  def chain_method(name, optimize = true, &block)
    name = name.to_s
    if instance_methods(false).include? name
      if optimize and defined? Ruby2Ruby
        code = Ruby2Ruby.translate self, name
        include Module.new { eval code }
      else
        # HACK. This part is pretty much a mean hack. Any super in the original
        # method has the potential to screw this up big time.
        # But Ruby2Ruby is not able to translate methods written in C (in MRI).
        # Maybe fall back to alias_method_chain?
        @__chained__ ||= []
        if @__chained__.include? name
          error = "you cannot chain a method twice without Ruby2Ruby."
          error << " do not set +optimize+ to false." unless optimize
          raise ArgumentError, error
        end
        m = instance_method name
        include Module.new { define_method(name) { |*a, &b| m.bind(self).call(*a, &b) } }
      end
    end
    block ||= Proc.new { super }
    define_method(name, &block)
  end

  def auto_chain &block
    raise ArgumentError, "no block given" unless block_given?
    result = nil
    class_eval do
      class << self
        chain_method :method_added do |name|
          return if @__chaining__
          @__chaining__ = true
          chain_method name
          @__chaining__ = false
        end
      end
      result = block.call
      class << self
        remove_method :method_added
      end
    end
    result
  end
    
end

Module.class_eval do
  include Chainable
  #private "auto_chain", "chain_method"
  private "chain_method"
end
