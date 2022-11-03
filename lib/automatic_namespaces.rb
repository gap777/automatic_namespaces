
require "active_support"
require_relative "automatic_namespaces/version"
require_relative "automatic_namespaces/stimpack_extension"

module AutomaticNamespaces

  class Error < StandardError; end
  extend ActiveSupport::Autoload

  autoload :StimpackExtension
  autoload :Railtie

  private_constant :StimpackExtension
end

require "automatic_namespaces/railtie"
