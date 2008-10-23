$LOAD_PATH << File.dirname(__FILE__) + '/acts_as_fu'

%w(rubygems activerecord constants).each { |lib| require lib }

module ActsAsFu
  def build_model(name, &block)
    ActiveRecord::Base.establish_connection({
      :adapter => "sqlite3",
      :database => ":memory:"
    })

    ActiveRecord::Base.connection.create_table name, :force => true do |table|
      table.instance_eval(&block)
    end

    klass_name = name.to_s.classify

    Object.send(:remove_const, klass_name) rescue nil
    Object.const_set(klass_name, Class.new(ActiveRecord::Base))
  end
end
