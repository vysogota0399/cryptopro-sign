# frozen_string_literal: true

require 'sinatra/custom_logger'
require 'sinatra/namespace'
require 'sinatra/json'

require_relative 'container'
require_relative 'import'

Cms.finalize!
