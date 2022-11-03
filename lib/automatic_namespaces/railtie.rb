require "rails/railtie"

module AutomaticNamespaces
  class Railtie < Rails::Railtie
    initializer 'automatic_namespaces' do
      StimpackExtension.new.enable_automatic_namespaces
    end
  end
end
