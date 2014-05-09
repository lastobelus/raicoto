module Raicoto
  module Inspection
    def ls(*attrs)
      ActiveRecord.without_logging do
        attrs.map!(&:to_s)
        attrs.unshift('id')
        attrs << 'name' if self.attribute_names.include?('name')
        attrs << 'title' if self.attribute_names.include?('title')
        attrs.uniq!
        lengths = {}
        records = self.all
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
  end
end