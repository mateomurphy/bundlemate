require 'rubygems'
require 'hoe'
require './lib/bundle_mate'

begin
  require 'spec/rake/spectask'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end

Hoe.new('bundlemate', BundleMate::VERSION::STRING) do |p|
  p.rubyforge_name = 'ljr'
  p.author = 'Luke Redpath'
  p.email = 'contact@lukeredpath.co.uk'
  p.summary = 'A command-line TextMate bundle manager.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = '' # p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps = [ ['plist', '>= 3.0.0'], ['simpleconsole', '>= 0.1.1'] ]
  p.test_globs = ["spec/**/*_spec.rb"]
end

desc "Run the specs under spec/models"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/*_spec.rb']
end

Rake::Task['default'].prerequisites.clear

desc "Default task is to run specs"
task :default => :spec