namespace :gemlock do
  desc 'list gems & versions'
  task :list => :environment do
    puts "Gemlock!"
  end
end
