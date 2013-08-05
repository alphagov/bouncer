require 'active_record'
RACK_ENV ||= ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection(YAML.load(File.read(File.expand_path('../config/database.yml', __FILE__)))[RACK_ENV])

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'digest/sha1'
require 'erb'
require 'nokogiri'
require 'ostruct'
require 'rack/request'
require 'uri'
require 'rendering_context'
require 'status_renderer'
require 'host'
require 'optic14n'
require 'bouncer/c14nizer'
require 'bouncer/env'
require 'bouncer'
