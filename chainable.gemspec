Gem::Specification.new do |s|
  s.name             = "chainable"
  s.version          = "0.2"
  s.authors          = ["Konstantin Haase"]
  s.date             = "2009-03-22"
  s.description      = "never use alias_method_chain, again"
  s.email            = "konstantin.mailinglists@googlemail.com"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files            = Dir["LICENSE", "Rakefile", "README.rdoc", "**/*.rb"]
  s.has_rdoc         = true
  s.homepage         = "http://rkh.github.com/chainable"
  s.require_paths    = ["lib"]
  s.rubygems_version = "1.3.1"
  s.summary          = s.description
  s.add_dependency("ruby2ruby")
end