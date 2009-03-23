require "ruby2ruby"

module Chainable

  def self.skip_chain
    return if @auto_chain
    @auto_chain = true
    yield
    @auto_chain = false
  end

  def self.wrapped_source klass, name, wrapper
    begin
      inner = unifier.process(parse_tree.parse_tree_for_method(klass, name))
      outer = unifier.process(parse_tree.parse_tree_for_proc(wrapper))
    rescue Exception
      raise ArgumentError, "cannot merge #{name}"
    end
    raise ArgumentError, "cannot merge #{name}" if inner[2] != s(:args) or outer[2]
    inner_locals = []
    sexp_walk(inner) do |e|
      raise ArgumentError, "cannot merge #{name}" if [:zsuper, :super].include? e[0]
      inner_locals << e if e[0] == :lvar
    end
    sexp_walk(outer) do |e|
      if inner_locals.include? e or (e[0] == :super and e.length > 1)
        raise ArgumentError, "cannot merge #{name}"
      end
      e.replace inner[3][1] if [:zsuper, :super].include? e[0]
    end
    src = Ruby2Ruby.new.process s(:defn, name, s(:args), s(:scope, s(:block, outer[3])))
    src.gsub "# do nothing", "nil"
  end

  def self.unifier
    return @unifier if @unifier
    @unifier = Unifier.new
    # HACK (stolen from ruby2ruby)
    @unifier.processors.each { |p| p.unsupported.delete :cfunc }
    @unifier
  end

  def self.parse_tree
    return @parse_tree if @parse_tree
    require "parse_tree"
    @parse_tree = ParseTree.new
  end

  # This will "chain" a method (read: push it to a module and include it).
  # If a block is given, it will do a define_method(name, &block).
  # Maybe that is not what you want, as methods defined by def tend to be
  # faster. If that is the case, simply don't pass the block and call def
  # after chain_method instead.
  def chain_method(*names, &block)
    options = names.grep(Hash).inject({}) { |a, b| a.merge names.delete(b) }
    if options[:try_merge]
      names.reject! do |name|
        begin
          merge_method(name, &block)
          true
        rescue ArgumentError
          false
        end
      end
    end
    names.each do |name|
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
  end

  def merge_method(*names, &block)
    names.each do |name|
      name = name.to_s
      unless instance_methods(false).include? name
        define_method(name, &block)
        next
      end
      class_eval Chainable.wrapped_source(self, name, block)
    end
  end

  def self.sexp_walk sexp, &block
    return unless sexp.is_a? Sexp
    yield sexp
    sexp.each { |e| sexp_walk e, &block }
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
