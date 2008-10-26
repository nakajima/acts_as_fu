module ActsAsFu
  def build_model(name, &block)
    ActiveRecord::Base.establish_connection({
      :adapter => "sqlite3",
      :database => ":memory:"
    })

    ActiveRecord::Base.connection.create_table(name, :force => true) { }
    
    klass_name = name.to_s.classify

    Object.send(:remove_const, klass_name) rescue nil
    Object.const_set(klass_name, Class.new(ActiveRecord::Base))
    
    klass = klass_name.constantize

    model_eval(klass, &block)
  end
  
  private
  
  def model_eval(klass, &block)
    class << klass
      def method_missing_with_columns(sym, *args, &block)
        ActiveRecord::Base.connection.change_table(name.tableize) do |t|
          t.send(sym, *args)
        end
      end
      
      alias_method_chain :method_missing, :columns
    end
    
    klass.class_eval(&block)
    
    class << klass
      alias_method :method_missing, :method_missing_without_columns
    end
  end
end
