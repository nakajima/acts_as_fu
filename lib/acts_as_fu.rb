$LOAD_PATH << File.dirname(__FILE__) + '/acts_as_fu'

module ActsAsFu
  VERSION = '0.0.2'
end

%w(rubygems activerecord constants helper).each { |lib| require lib }
