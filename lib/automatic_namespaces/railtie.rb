require "rails/railtie"

module AutomaticNamespaces
  class Railtie < Rails::Railtie
    initializer 'automatic_namespaces' do
      Autoloader.new.enable_automatic_namespaces
    end
  end
end
