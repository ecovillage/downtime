require "downtime/version"
require "downtime/timestamp"

module Downtime
  class DowntimeCheck
    attr_accessor :host
    attr_accessor :log_file

    def initialize
      @host = "8.8.8.8"
      @log_file = "downtime.log"
    end

    def perform
      ensure_logfile
      timestamp!
      check_and_update_file
    end

    private

    def check_and_update_file
      lines = File.readlines @log_file
      was_down = lines[-1] =~ /down/
      up = is_up?
      minutes = 0
      if lines.length > 1
        first_timestamp = lines[-1][/^[0-9-]*/]
        minutes = (@timestamp - Timestamp.from_s(first_timestamp))
        puts minutes
      end
      if was_down || lines.length <= 1
        if up
          # "went up"
          lines << "! went up after #{minutes} minutes of downtime."
          lines << "#{@timestamp} up till #{@timestamp}"
        else
          # "stayed down"
          # Modify last line.
          lines[-1].gsub!(/till.*/, "till #{@timestamp}")
        end
      else
        # was up before
        if up
          # "stayed up."
          # Modify last line.
          lines[-1].gsub!(/till.*/, "till #{@timestamp}")
        else
          # "went down."
          lines << "! went down after #{minutes} minutes of uptime."
          lines << "#{@timestamp} down till #{@timestamp}"
        end
      end
      File.open(@log_file, 'w') do |f|
        f.puts lines
      end
    end

    def is_up? host=nil
      host = @host if host.nil?
      dig = `dig +time=1 +tries=1 #{host}`
      dig.lines.find {|l| l =~ /time.*ms/}
    end

    def ensure_logfile
      return if File.exist? @log_file
      append_to_logfile "# This file is created by the downtime #{Downtime::VERSION} ruby gem."
    end

    def timestamp!
      @timestamp = Timestamp.new
    end
  end
end
