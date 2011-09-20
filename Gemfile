source :gemcutter

activerecord_version = ENV['ACTS_AS_FU_ACTIVERECORD_VERSION']

if activerecord_version == "edge"
  git "https://github.com/rails/rails.git" do
    gem "activerecord"
    gem "activesupport"
  end
elsif activerecord_version && activerecord_version.strip != ""
  gem "activerecord", activerecord_version
else
  gem "activerecord"
end

gem "sqlite3-ruby"

group :development do
  gem "rspec", "~>1"
end
