# Run in development, compile a settings.yml from the settings.secret.yml

# APP_NAME=balaus-staging rake heroku:vars

require 'yaml'
require 'rubygems'
require 'ruby-debug'
require 'deep_merge'


@public_config_path = File.join(File.dirname(__FILE__), *%w(.. .. config settings.yml))
@settings_loader_path = File.join(File.dirname(__FILE__), *%w(.. .. config settings.loader.sh))

class String
  def escape_single_quotes
    self.gsub(/'/, "\\\\'")
  end
  def escape_double_quotes
    self.gsub(/"/, '\\\\"')
  end
end

# derived from DFS in nested hashes
# http://gist.github.com/326558
def dfs(n)
  case n
  when Hash
    n.each do |k,v|
      @stack.push k
      dfs(v)
      @stack.pop
    end
  else
    tmp = Array.new(@stack).push "<%= ENV['#{@stack.join('__').upcase}'] =>"
    @new_config.deep_merge!(tmp.reverse.inject { |mem, var| {var => mem}})
    @env_vars[@stack.join('__').upcase] = n
  end
end


namespace :heroku do
  namespace :vars do
    desc "Loads initial database models for the current environment."
    task :setup => :environment do

      application_name = ENV['APP_NAME']

      if application_name.nil?
        puts "ERROR: APP_NAME not specified ( APP_NAME=someapp-staging rake heroku:vars )"
        exit 1
      end

      config_file_path = File.join(File.dirname(__FILE__), *%w(.. .. config settings.secret.yml))

      if File.exist?(config_file_path)
        config = YAML.load_file(config_file_path)[RAILS_ENV]

        if config.nil?
          puts "ERROR: config for RAILS_ENV(#{RAILS_ENV}) not found."
          exit 1
        end

        # pull squash all the values into an environment variable-friendly format
        @stack = []
        @new_config = {}
        @env_vars = {}
        dfs(config)

        # produce a settings.yml from this

        puts "  creating #{@public_config_path}"
        File.open( @public_config_path, 'w' ) do |out|
          out.write "#\n# Do Not Edit. This file is autogenerated by #{File.basename(__FILE__)}\n#\n"
          out.write "#This file can be committed to a public repo as it only references environment variables\n"
          out.write "#Dont forget to run the heroku config loader first: rake heroku:vars:load \n"
          YAML.dump( @new_config, out )
        end

        puts "  creating #{@settings_loader_path}"
        File.open( @settings_loader_path, 'w' ) do |out|
          out.write "#\n# Do Not Edit. This file is autogenerated by #{File.basename(__FILE__)}\n#\n"
          @env_vars.each do |key, value|
            out.write "heroku config:add #{key}=\"#{value.to_s.escape_double_quotes}\" --app #{application_name}\n"
          end
        end

        puts "Heroku config generated. Now run the heroku config loader: with rake heroku:vars:load\n"

      else
        puts "WARNING: secret configuration file #{config_file_path} not found."
        APP_CONFIG = {}
      end
    end

    desc "Load the autogenerated heroku config vars to your heroku app."
    task :add do
      puts "adding heroku config for your app using #{@settings_loader_path}"
      system "/usr/bin/env sh #{@settings_loader_path}"
    end

    task :push => :add #alias
    task :load => :add #alias
    task :default => :setup
  end
end

