class ::Array
  include Raicoto::Inspection
  
  def ls(*attrs)
    ActiveRecord.without_logging do
      attrs.map!(&:to_s)
      attrs.unshift('id')
      attrs << 'name' if self._attribute_names.include?('name')
      attrs << 'title' if self._attribute_names.include?('title')
      attrs.uniq!
      lengths = {}
      records = self._all_for_ls
      if records.count < 1
        puts "No Records."
        return
      end
      records.each do |r|
        attrs.each do |a|
          val = r
          a.split('.').map{|path| val = val.send(path)}
          len = val.to_s.length
          lengths[a] ||= a.length
          lengths[a] = [lengths[a], len].max
        end
      end
      out = [attrs.map{|a| a.rjust(lengths[a]+1)}.join]
      out += records.map { |r|
        line = ""
        attrs.each do |a|
          val = r
          a.split('.').map{|path| val = val.send(path)}
          line << val.to_s.rjust(lengths[a]+1)
        end
        line
      }
      out.each{|s| puts s }
      out.length - 1
    end
  end

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