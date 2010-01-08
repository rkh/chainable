require 'spec/rake/spectask'
task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << "-fs"
end

desc "Run benchmark"
task(:benchmark) { load "benchmark/chainable.rb" }