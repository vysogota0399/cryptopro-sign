# frozen_string_literal: true

require 'sinatra/custom_logger'
require 'sinatra/namespace'
require 'sinatra/json'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require_relative 'container'
require_relative 'import'

Cms.finalize!
