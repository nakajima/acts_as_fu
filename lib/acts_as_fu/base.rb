%w(rubygems active_record).each { |lib| require lib }

RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined?(RAILS_ROOT)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)

module ActsAsFu

  class Connection < ActiveRecord::Base
    cattr_accessor :connected
    cattr_reader :log
    self.abstract_class = true

    def self.connect!(config={})
      @@log = ""
      self.logger = Logger.new(StringIO.new(log))
      self.connection.disconnect! rescue nil
      self.establish_connection(config)
    end
  end

  def build_model(name, options={}, &block)
    connect! unless connected?

    klass_name  = name.to_s.classify
    super_class = options[:superclass] || ActsAsFu::Connection
    contained   = options[:contained]  || Object

    contained.send(:remove_const, klass_name) rescue nil
    klass = Class.new(super_class)
    contained.const_set(klass_name, klass)

    # table_name isn't available until after the class is created.
    if super_class == ActsAsFu::Connection
      ActsAsFu::Connection.connection.create_table(klass.table_name, :force => true) { }
    end

    model_eval(klass, &block)
    klass
  end

  private

  def connect!
    ActsAsFu::Connection.connect!({
      :adapter => "sqlite3",
      :database => ":memory:"
    })
    ActsAsFu::Connection.connected = true
  end

  def connected?
    ActsAsFu::Connection.connected
  end

  def model_eval(klass, &block)
    class << klass
      def method_missing_with_columns(sym, *args, &block)
        ActsAsFu::Connection.connection.change_table(table_name) do |t|
          t.send(sym, *args)
        end
      end

      alias_method_chain :method_missing, :columns
    end

    klass.class_eval(&block) if block_given?

    class << klass
      remove_method :method_missing
      alias_method :method_missing, :method_missing_without_columns
    end
  end

end
