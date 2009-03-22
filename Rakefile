require 'spec/rake/spectask'

Spec::Rake::SpecTask.new { |t| t.spec_files = FileList['spec/**/*.rb'] }

desc "Run benchmark"
task(:benchmark) { load "benchmark/chainable.rb" }