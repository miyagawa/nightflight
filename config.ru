$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
require 'app'

run Sinatra::Application

