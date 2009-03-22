require "benchmark"
require "lib/chainable"
require "active_support"

class BenchmarkChain
  CHAIN_LENGTH = 1000
  CALL_TIMES = 100
  class << self
    def bm1(x)
      obj = new
      x.report("#{@name} (define_method)") { CALL_TIMES.times { obj.bm1 } }
    end
    def bm2(x)
      obj = new
      x.report("#{@name} (def & eval)") { CALL_TIMES.times { obj.bm2 } }
    end
  end
  define_method(:bm1) { 100 }
  def bm2; 100; end
end

class BenchmarkChainable < BenchmarkChain
  @name = "chainable"
  CHAIN_LENGTH.times do
    chain_method(:bm1) { super * 2 }
    chain_method(:bm2)
    def bm2; super * 2; end
  end
end

class BenchmarkAliasMethodChain < BenchmarkChain
  @name = "alias_method_chain"
  CHAIN_LENGTH.times do |i|
    define_method("bm1_with_#{i}") { send("bm1_without_#{i}") * 2 }
    alias_method_chain :bm1, i.to_s
    eval "def bm2_with_#{i}; bm2_without_#{i} * 2; end"
    alias_method_chain :bm2, i.to_s
  end
end

def bench(x, klass)
  obj = klass.new
end

Benchmark.bmbm do |x|
  BenchmarkChainable.bm1(x)
  BenchmarkAliasMethodChain.bm1(x)
  BenchmarkChainable.bm2(x)
  BenchmarkAliasMethodChain.bm2(x)
end