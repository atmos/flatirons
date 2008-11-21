require 'rubygems'
require 'rake/rdoctask'

require 'merb-core'
require 'merb-core/tasks/merb'

include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)

# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each{|rake_file| load rake_file }

desc "Start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

require 'spec/rake/spectask'
require 'merb-core/test/tasks/spectasks'
desc 'Default: run spec examples'
task :default => 'spec'

##############################################################################
# ADD YOUR CUSTOM TASKS IN /lib/tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################
namespace :spec do
  task :update_gems do |t|
    system("script/update")
  end
  Spec::Rake::SpecTask.new(:ci => [:update_gems]) do |t|
    t.spec_opts << %w(-fs --color) << %w(-O spec/spec.opts)
    t.spec_opts << '--loadby' << 'random'
    t.spec_files = %w(controllers models helpers views).collect { |dir| Dir["spec/#{dir}/**/*_spec.rb"] }.flatten
    t.rcov = ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true
    t.rcov_opts << '--exclude' << 'spec/,config/,exceptions,schema,gems/gems,merb/'
    t.rcov_opts << '--text-summary'
    t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  end
end
