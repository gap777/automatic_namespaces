
require "active_support"
require_relative "automatic_namespaces/version"
require_relative "automatic_namespaces/autoloader"

module AutomaticNamespaces

  class Error < StandardError; end
  extend ActiveSupport::Autoload

  autoload :Autoloader
  autoload :Railtie

  private_constant :Autoloader
end

require "automatic_namespaces/railtie"
