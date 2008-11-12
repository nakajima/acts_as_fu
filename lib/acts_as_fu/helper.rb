module ActsAsFu
  class << self
    attr_reader :log
  
    def connect!(config={})
      @log = ""
      ActiveRecord::Base.logger = Logger.new(StringIO.new(log))
      ActiveRecord::Base.establish_connection(config)
    end
  end
  
  def build_model(name, options={}, &block)
    connect!
    
    super_class = options[:superclass] || begin
      ActiveRecord::Base.connection.create_table(name, :force => true) { }
      ActiveRecord::Base
    end
    
    set_class!(name, super_class, &block)
  end
  
  private
  
  def set_class!(name, super_class, &block)
    klass_name = name.to_s.classify
    Object.send(:remove_const, klass_name) rescue nil
    
    klass = Class.new(super_class)
    Object.const_set(klass_name, klass)

    model_eval(klass, &block)
  end

  def connect!
    begin
      # This blows up if there's no connection
      ActiveRecord::Base.connection
    rescue
      ActsAsFu.connect!({
        :adapter => "sqlite3",
        :database => ":memory:"
      })
    end
  end
  
  def model_eval(klass, &block)
    class << klass
      def method_missing_with_columns(sym, *args, &block)
        ActiveRecord::Base.connection.change_table(name.tableize) do |t|
          t.send(sym, *args)
        end
      end
      
      alias_method_chain :method_missing, :columns
    end
    
    klass.class_eval(&block) if block_given?
    
    class << klass
      alias_method :method_missing, :method_missing_without_columns
    end
  end
end
