require 'yaml'

class AutomaticNamespaces::StimpackExtension

  def enable_automatic_namespaces
    namespaced_packages.each do |package_file|
      pack_root_dir = File.dirname(package_file)
      package_namespace = define_namespace(pack_root_dir)
      pack_directories(pack_root_dir).each do |pack_dir|
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

  def define_namespace(pack_root_dir)
    package_directory = File.basename(pack_root_dir).to_s
    package_name = package_directory.camelize
    Object.const_set(package_name, Module.new)
    package_name.constantize
  end

  def namespaced_packages
    Stimpack::Packs.all.map { |pack| pack.path.join('package.yml').to_s }.select { |package_file| has_automatic_namespace?(package_file) }
  end

  def has_automatic_namespace?(package_file)
    package_description = YAML.load_file(package_file)
    metadata = package_description["metadata"]
    metadata && metadata["automatic_pack_namespace"]
  end
end




