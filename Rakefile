require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "party_resource"
    gem.summary = %Q{Simple REST interface for ruby objects.}
    gem.description = %Q{party_resource is a framework for building ruby objects which interact with a REST api. Built on top of HTTParty.}
    gem.email = "dev+party_resource@edendevelopment.co.uk"
    gem.homepage = "http://github.com/edendevelopment/party_resource.git"
    gem.authors = ["Tristan Harris", "Steve Tooke"]
    gem.add_runtime_dependency "httparty", ">= 0.5.2"
    gem.add_runtime_dependency "activesupport", ">= 2.3.5"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "webmock", ">= 0"
    gem.files = FileList['lib/**/*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = 'spec/unit/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = 'spec/integration/**/*_spec.rb'
  end
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts =  %q[--exclude "spec"]
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--no-private']
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

begin
  require 'metric_fu'

rescue LoadError
  task :"metrics:all" do
    abort "metric_fu is not available. gem install metric_fu"
  end
end
