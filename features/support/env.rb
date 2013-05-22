PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../../config/boot")

require 'capybara/cucumber'
require 'rspec/expectations'
require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'rack'
require 'rack/test'

##
# You can handle all padrino applications using instead:
#   Padrino.application
Capybara.app = Reactor2::App.tap { |app|  }

def app
  Rack::Lint.new(Capybara.app)
end