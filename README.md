# ACTS-AS-FU

Now you have no excuse for not test-driving your ActiveRecord
extending plugins.

### Usage

In your spec_helper.rb (pretty sure this works with `Test::Unit`
too, I'll leave you to figure it out though)

    require 'rubygems'
    require 'acts_as_fu'
    require 'spec'
  
    Spec::Runner.configure do |config|
      config.include ActsAsFu
    end

Then in your specs:

    describe "acts_as_gilmore_girls" do
      before(:each) do
        build_model :nerds do
          text :omg_omg_bio
          string :name
          string :favorite_scene
      
          validates_presence_of :favorite_scene
      
          def awesome?(show_name)
            show_name == "Gilmore Girls"
          end      
        end
      end

      it "should require favorite scene" do
        nerd = Nerd.new :favorite_scene => nil
        nerd.should_not be_valid
        nerd.errors.on(:favorite_scene).should_not be_nil
      end

      it "should think gilmore girls is awesome"
        nerd = Nerd.new
        nerd.awesome?("Gilmore Girls").should be_true
      end

      it "has other stuff" do
        # ETC!
      end
    end
  
The `build_model` method allows you to build an ActiveRecord model on
the fly. It takes a block where you can specify columns and methods.

#### Single Table Inheritance

If you want to create a model that's a subclass of another, you can
use the `:superclass` option:

    build_model(:assets) do
      string :type
      string :name
      named_scope :pictures, :conditions => { :type => "Picture" }
    end

    build_model(:pictures, :superclass => Asset)

The `Picture` model will then be a subclass of the `Asset` model.

#### Custom database configuration

If the in-memory sqlite3 database doesn't suit your needs, you can
specify an alternative configuration with the `ActsAsFu.connect!` method:

    ActsAsFu.connect! \
      :adapter => 'mysql',
      :database => 'some-db',
      :username => 'some-user',
      :password => 'some-password',
      :socket => '/path/to/mysql.sock'

### Install

    $ gem install nakajima-acts_as_fu --source=http://gems.github.com

TODO

Provide the ability to create **multiple** connections (thanks to Pivotal for the idea):
      
    ActsAsFu.connections[:sqlite3] # or something

(c) Copyright 2008-2009 Pat Nakajima. All Rights Reserved.