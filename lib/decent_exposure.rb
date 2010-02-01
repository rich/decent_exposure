module DecentExposure
  def expose(name, &block)
    block ||= lambda {_class_for(name).find(params["#{name}_id"] || params['id'])}
    resource_name = "#{name}_resource"

    define_method(resource_name, &block)
    class_eval <<-EOT
  def #{name}
    @_#{resource_name} ||= #{resource_name}
  end
EOT

    [name, resource_name].each do |n|
      helper_method n
      hide_action n
    end
  end

  alias let expose

  private
  def _class_for(name)
    name.to_s.classify.constantize
  end
end

