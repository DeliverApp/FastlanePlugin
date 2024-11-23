lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/deliverapp/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-deliverapp'
  spec.version       = Fastlane::Deliverapp::VERSION
  spec.author        = 'JD'
  spec.email         = 'julien.dumont007@gmail.com'

  spec.summary       = '"Publish your build to https://store.deliverapp.io/ with several usefull informations"'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-deliverapp"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'
  spec.add_dependency "apktools"
  spec.add_dependency "plist"

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
end
