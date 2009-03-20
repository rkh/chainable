Gem::Specification.new do |s|
  s.name             = "chainable"
  s.version          = "0.0.1"
  s.authors          = ["Konstantin Haase"]
  s.date             = "2009-03-20"
  s.description      = "never use alias_method_chain, again"
  s.email            = "konstantin.mailinglists@googlemail.com"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files            = Dir["LICENSE", "Rakefile", "README.rdoc", "**/*.rb"]
  s.has_rdoc         = true
  s.homepage         = "http://rkh.github.com/chainable"
  s.require_paths    = ["lib"]
  s.rubygems_version = "1.3.1"
  s.summary          = s.description

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end