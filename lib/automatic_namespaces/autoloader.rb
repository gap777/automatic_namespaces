require 'yaml'

class AutomaticNamespaces::Autoloader

  def enable_automatic_namespaces
    namespaced_packages.each do |pack, metadata|
      package_namespace = define_namespace(pack, metadata)
      pack_directories(pack.path).each do |pack_dir|
        set_namespace_for(pack_dir, package_namespace)
      end
    end
  end

  private

  def set_namespace_for(pack_dir, package_namespace)
    Rails.logger.debug { "Associating #{pack_dir} with namespace #{package_namespace}" }
    ActiveSupport::Dependencies.autoload_paths.delete(pack_dir)
    Rails.autoloaders.main.push_dir(pack_dir, namespace: package_namespace)
    Rails.application.config.watchable_dirs[pack_dir] = [:rb]
  end

  PACK_SUBDIRS = [
    'app/components',
    'app/controllers',
    'app/event_handlers',
    'app/events',
    'app/models',
    'app/public',
    'app/services',
    'app/views'
  ]

  def pack_directories(pack_root_dir)
    PACK_SUBDIRS.map {|subdir| Dir.glob("#{pack_root_dir}/#{subdir}") }
                .flatten
                .select { |pack_dir| File.exist?(pack_dir) }
  end

  def define_namespace(pack, metadata)
    namespace = metadata['namespace_override'] || pack.name.camelize
    Object.const_set(namespace, Module.new)
    namespace.constantize
  end

  def namespaced_packages
    Stimpack::Packs.all
                   .map {|pack| [pack, package_metadata(pack)] }
                   .select {|pack, metadata| metadata && metadata["automatic_pack_namespace"] }
  end

  def package_metadata(pack)
    package_file = pack.path.join('package.yml').to_s
    package_description = YAML.load_file(package_file)
    package_description["metadata"]
  end
end




