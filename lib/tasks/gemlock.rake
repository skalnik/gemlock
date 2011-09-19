namespace :gemlock do
  desc 'list gems & versions'
  task :list => :environment do
    Gemlock.locked_gemfile_specs.each do |spec|
      puts "#{spec.name}, version = #{spec.version.to_s}"
    end
  end
end
