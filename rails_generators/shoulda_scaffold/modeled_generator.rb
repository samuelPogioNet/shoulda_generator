class ModeledGenerator < Rails::Generator::NamedBase
  def model_exists?
    @model_exists ||= File.exist?("app/models/#{file_path}.rb")
  end

  def update_model_info()
    unless File.exist?("app/models/#{file_path}.rb")
      if class_nesting_depth == 0
        raise "#{model_name} not exists in models" 
      end
      if !File.exist?("app/models/#{class_name.demodulize.underscore}.rb")
        raise "#{model_name} nor #{class_name.demodulize.underscore} not exists in models"
      end
      assign_names!(class_name.demodulize)
    end
  end

  protected
  def attributes
    @attributes ||= if model_exists?
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
        columns = klass.columns.reject{|field| %q(id created_at updated_at).include? field.name.to_s }
        columns.collect do |field|
          attribute = "#{field.name.to_s}:#{field.type.to_s}"
          Rails::Generator::GeneratedAttribute.new(*attribute.split(":"))
        end
      else
       super
      end
  end
end
