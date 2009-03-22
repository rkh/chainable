require "benchmark"
require "lib/chainable"
require "active_support"

class BenchmarkChainable
  def name
    "chainable"
  end
  def bm1
    100
  end
  def bm2
    100
  end
  1000.times do
    chain_method(:bm1) { super * 2 }
    chain_method :bm2
    def bm2
      super * 2
    end
  end
end

class BenchmarkAliasMethodChain
  def name
    "alias_method_chain"
  end
  def bm1
    100
  end
  def bm2
    100
  end
  1000.times do |i|
    define_method("bm1_with_#{i}") { send("bm1_without_#{i}") * 2 }
    alias_method_chain :bm1, i.to_s
    eval "def bm2_with_#{i}; bm2_without_#{i} * 2; end"
    alias_method_chain :bm2, i.to_s
  end
end

def bench(x, klass)
  obj = klass.new
  x.report("#{obj.name} (define_method)") { 100.times { obj.bm1 } }
  x.report("#{obj.name} (def & eval)") { 100.times { obj.bm2 } }
end

Benchmark.bmbm do |x|
  bench(x, BenchmarkChainable)
  bench(x, BenchmarkAliasMethodChain)
end