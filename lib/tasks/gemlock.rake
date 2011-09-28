namespace :gemlock do
  desc 'list gems & versions'
  task :list => :environment do
    Gemlock.locked_gemfile_specs.each do |spec|
      puts "#{spec.name}, version = #{spec.version.to_s}"
    end
  end

  desc 'lists out of date gems'
  task :outdated => :environment do
    outdated = Gemlock.outdated
    if outdated.empty?
      puts "All gems up to date!"
    else
      outdated.each_pair do |name, versions|
        puts "#{name} is out of date!"
        puts "Installed version: #{versions[:current]}. Latest version: #{versions[:latest]}"
        puts "To update: bundle update #{name}"
      end
      puts ""
      puts "To update all your gems via bundler:"
      puts "bundle update"
    end
  end
end
