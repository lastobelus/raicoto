class ActiveRecord::Base
  def self.ls(*attrs)
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

module ActiveRecord
  def self.without_logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    result = yield
    ActiveRecord::Base.logger = old_logger
    result
  end
  
  def self.counts
    klasses = []
    without_logging do
      tables = ActiveRecord::Base.connection.tables
      col = tables.map(&:length).max
      out =  "Current Record Counts\n"
      out << ("-"*col)+"------\n"
      total = 0
      tables.each do |table|
        next if table.match(/\Aschema_migrations\Z/)
        begin
          klass = table.singularize.camelize.constantize
          klasses << klass
          count = klass.count
          total += count
          out << "#{klass.name.ljust(col)} #{count.to_s.rjust(5)}"
          out << "\n"
        rescue
          sql = "Select count(*) from #{table}"
          result = ActiveRecord::Base.connection.execute(sql)
          count = result.first['count']
          total += count.to_i
          out << ".#{table.ljust(col)} #{count.rjust(5)}"
          out << "\n"
        end
      end
      out << ("-"*col)+"------\n"
      puts out
      puts "#{total} records in #{tables.length} tables."
    end
    klasses
  end
end