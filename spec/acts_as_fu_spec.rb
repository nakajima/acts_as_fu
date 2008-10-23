require File.dirname(__FILE__) + '/spec_helper'

describe ActsAsFu do
  include ActsAsFu
  
  def build_foos
    build_model(:foos) do
      string :name
      integer :age
    end
  end
  
  describe "without building a model" do
    it "asplodes" do
      proc {
        Foo
      }.should raise_error(NameError)
    end
  end
  
  describe "after building a model" do
    before(:each) do
      build_foos
    end
    
    it "creates the class" do
      proc {
        Foo
      }.should_not raise_error
    end
    
    describe "the class" do
      it "is a subclass of ActiveRecord::Base" do
        Foo.superclass.should == ActiveRecord::Base
      end
      
      it "has specified attributes" do
        foo = Foo.create! :name => "The WHIZ", :age => 100
        foo.name.should == "The WHIZ"
        foo.age.should == 100
      end
      
      it "is really real" do
        Foo.validates_presence_of :name
        proc {
          Foo.create! :age => 100
        }.should raise_error(ActiveRecord::RecordInvalid)
      end      
    end
    
    describe "rebuilding the class" do
      before(:each) do
        5.times { Foo.create!(:name => "The WHIZ", :age => 100) }
      end
      
      it "clears the table" do
        Foo.count.should == 5
        build_foos
        Foo.count.should == 0
      end
      
      it "resets the class" do
        class << Foo; attr_reader :bar end
        
        proc { Foo.bar }.should_not raise_error
        
        build_foos
        
        proc {
          Foo.bar
        }.should raise_error(NoMethodError)
      end
    end
  end
end