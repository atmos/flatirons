project_root = File.expand_path(File.dirname(__FILE__))
require File.join(project_root, 'vendor', 'gems', 'environment')
require 'merb-core'

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'development'
Merb.load_dependencies(:environment => init_env)

desc "Start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

require 'spec/rake/spectask'
desc 'Default: run spec examples'
task :default => 'spec'
##############################################################################
# ADD YOUR CUSTOM TASKS IN /lib/tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts << %w(-fs --color) << %w(-O spec/spec.opts)
  t.spec_opts << '--loadby' << 'random'
  t.spec_files = %w(requests mailers models helpers views).collect { |dir| Dir["spec/#{dir}/**/*_spec.rb"] }.flatten
  t.rcov = ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true
  t.rcov_opts << '--exclude' << 'spec/,config/,exceptions,schema,gems/gems,merb/'
  t.rcov_opts << '--text-summary'
  t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
end
