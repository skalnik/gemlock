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
      end
    end
  end
end
