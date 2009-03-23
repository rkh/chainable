require "benchmark"
require "lib/chainable"
require "active_support"

class BenchMe

  CALL_TIMES = 5000
  DEF_TIMES = 500
  BENCH_ME = []

  def self.report
    @report || "unknown"
  end

  def self.inherited klass
    BENCH_ME << klass
    klass.class_eval "def a_method; nil; end"
  end

  def self.run
    Benchmark.bmbm do |x|
      BENCH_ME.each do |klass|
        object = klass.new
        x.report(klass.report) { CALL_TIMES.times { object.a_method } }
      end
    end
  end

end

class NoWrappers < BenchMe
  @report = "no wrappers"
end

class MergeMethod < BenchMe
  @report = "merge_method"
  DEF_TIMES.times { merge_method(:a_method) { super } }
end

class ChainMethodDef < BenchMe
  @report = "chain_method (def)"
  DEF_TIMES.times do
    chain_method(:a_method)
    def a_method; super; end
  end
end

class ChainMethod < BenchMe
  @report = "chain_method (define_method)"
  DEF_TIMES.times { chain_method(:a_method) { super } }
end

class AliasMethodChainDef < BenchMe
  @report = "alias_method_chain (def)"
  DEF_TIMES.times do |i|
    eval "def a_method_with_#{i}; a_method_without_#{i}; end"
    alias_method_chain :a_method, i
  end
end

class AliasMethodChain < BenchMe
  @report = "alias_method_chain (define_method)"
  DEF_TIMES.times do |i|
    without = "a_method_without_#{i}".to_sym
    define_method("a_method_with_#{i}") { send without }
    alias_method_chain :a_method, i
  end
end

BenchMe.run