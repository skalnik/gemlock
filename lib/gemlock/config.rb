module Gemlock
  module Config
    class << self
      def file
        if defined?(Rails) && File.exists?(Rails.root.join('config', 'gemlock.yml'))
          Rails.root.join('config', 'gemlock.yml')
        end
      end

      def parsed
        parsed = YAML.load_file(file) if file
      end

      def email
        email = parsed['email'] if parsed

        if email =~ /^[^@]+@[^@]+$/
          email
        else
          nil
        end
      end

      def update_interval
        if parsed
          if parsed["interval"]
            interval = parsed["interval"][0]

            num_hours = interval.match(/\d*/)[0].to_i
            if interval =~ /hour/
              delay = 60*60
            elsif interval =~ /day/
              delay = 60*60*24
            elsif interval =~ /week/
              delay = 60*60*24*7
            elsif interval =~ /month/
              delay = 60*60*24*30
            end
            if delay && num_hours > 0
              delay *= num_hours
              return delay
            elsif delay
              return delay
            end
          end
        end
        60*60*24*7 #Seconds in a week
      end
    end
  end
end
