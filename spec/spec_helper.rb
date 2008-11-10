require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.mock_with(:rr)
  
  def query_parse(query_string, delimiter = '&;', preserve_order = false)
    query = preserve_order ? Dictionary.new : {}
    for pair in (query_string || '').split(/[#{delimiter}] */n)
      key, value = URI.unescape(pair).split('=',2)
      next if key.nil?
      if key.include?('[')
        normalize_params(query, key, value)
      else        
        query[key] = value
      end
    end
    preserve_order ? query : query.to_mash
  end
end
