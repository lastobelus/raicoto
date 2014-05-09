class ActiveRecord::Base
  extend Raicoto::Inspection
  def self._all_for_ls
    self.all
  end
  
  def self.map(&block)
    self.all.map(&block)
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
          out << ".#{table.ljust(col-1)} #{count.rjust(5)}"
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