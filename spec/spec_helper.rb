require File.dirname(__FILE__) + '/../../../../spec/spec_helper'

#The stuff below is for specs that need an active database to store datae
# into for tests.  Since the om plugin assumes that all data retrieval is
# over the net, this isn't necessary

#require 'fileutils'

#plugin_spec_dir = File.dirname(__FILE__)
#ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

#databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
# remove existing database (no way to create transactions for the plugin?)
#db = databases[ENV["DB"] || "sqlite3"]
#begin
#  FileUtils.rm plugin_spec_dir + "/db/#{db[:dbfile]}" if File.exist?
#rescue
#end
#ActiveRecord::Base.establish_connection(db)
#load(File.join(plugin_spec_dir, "db", "schema.rb"))
