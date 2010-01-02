module Rifgraf
  class CLI
    def self.run(args = ARGV)
      new(args).run
    end

    def initialize(args)
      @args = args
    end

    def run
      case command = @args.shift
      when "serve"
        Rack::Handler.get("webrick").run(Rackup, :Port => 8080)
      when "post"
        url = "http://localhost:8080"
        name = @args.shift
        value = @args.shift
        timestamp = @args.shift || Time.now
        response = Rack::Client.post("#{url}/#{name}", :timestamp => timestamp, :value => value)
        if response.successful?
          puts "Reported"
        else
          puts "Failed"
        end
      else
        abort "Unknown command: #{command}"
      end
    end
  end
end
