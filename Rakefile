
namespace :spec do
  desc "run specs against multiple versions of rails"
  task :all do
    Dir["Gemfile-*"].sort.each do |gemfile|
      next if gemfile =~ /lock/
      puts "* running specs under #{gemfile} ..."
      FileUtils.rm_f "Gemfile"
      FileUtils.cp gemfile, "Gemfile"
      system("bundle install") || raise("could not bundle #{gemfile}")
      system("bundle exec spec spec")
    end
  end
end
