lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "spotlight_search/version"

Gem::Specification.new do |s|
  s.name        = 'spotlight_search'
  s.version     = SpotlightSearch::VERSION
  s.date        = '2019-05-29'
  s.summary     = "This gem should help reduce the efforts in the admin panel.
  It has search, sort and pagination included."
  s.description = "This gem should help reduce the efforts in the admin panel.
  It has search, sort and pagination included"
  s.authors     = ["Anbazhagan Palani"]
  s.email       = 'anbu@commutatus.com'
  s.homepage    =
    'https://github.com/commutatus/spotlight-search'
  s.license       = 'MIT'
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  # s.bindir        = "exe"
  # s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
