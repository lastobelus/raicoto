class ::Array
  include Raicoto::Inspection
  
  def _all_for_ls
    self
  end

  def _attribute_names
    return [] if empty?
    case true
    when first.respond_to?(:attribute_names)
      first.attribute_names
    when first.respond_to?(:attributes)
      first.attributes.keys
    when first.respond_to?(:keys)
      first.keys
    else
      raise "don't know how to get attribute_names for #{first.inspect}"
    end
    
  end
end