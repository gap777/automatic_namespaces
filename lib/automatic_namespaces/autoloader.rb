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

  def pack_directories(pack_root_dir)
    Dir.glob("#{pack_root_dir}/**/app/*").reject { |dir| non_namspaced_directory(dir) }
  end

  def non_namspaced_directory(dir)
    dir.include?('/app/assets') ||
      dir.include?('/app/helpers') || # Rails assumes helpers are global, not namespaced
      dir.include?('/app/inputs') || # Not sure how to namespace form inputs
      dir.include?('/app/javascript') ||
      dir.include?('/app/views')
  end

  def define_namespace(pack, metadata)
    namespace_name = metadata['namespace_override'] || pack.last_name.camelize
    namespace_object = Object
    namespace_name.split('::').each do |module_name|
      namespace_object = namespace_object.const_set(module_name, Module.new)
    end
    namespace_object
  end

  def namespaced_packages
    Packs.all
         .map {|pack| [pack, package_metadata(pack)] }
         .select {|_pack, metadata| metadata && metadata["automatic_pack_namespace"] }
  end

  def package_metadata(pack)
    package_file = pack.path.join('package.yml').to_s
    package_description = YAML.load_file(package_file) || {}
    package_description["metadata"]
  end
end




