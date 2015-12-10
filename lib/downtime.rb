require "downtime/version"
require "downtime/timestamp"

module Downtime
  class DowntimeCheck
    attr_accessor :ip
    attr_accessor :host
    attr_accessor :log_file

    def initialize
      @ip = "8.8.8.8"
      @host = "http://siebenlinden.de"
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
      up = is_up_wget?
      minutes = 0
      if lines.length > 1
        first_timestamp = lines[-1][/^[0-9-]*/]
        minutes = (@timestamp - Timestamp.from_s(first_timestamp))
      end
      if was_down || lines.length <= 1
        if up
          # "went up"
          lines << "! went up after #{minutes} minutes of downtime."
          lines << "#{@timestamp} up till #{@timestamp}"
        else
          # "stayed down"
          # Modify last line.
          lines[-1].gsub!(/till.*/, "till #{@timestamp} (#{minutes} minutes)")
        end
      else
        # was up before
        if up
          # "stayed up."
          # Modify last line.
          lines[-1].gsub!(/till.*/, "till #{@timestamp} (#{minutes} minutes)")
        else
          # "went down."
          lines << "! went down after #{minutes} minutes of uptime."
          lines << "#{@timestamp} down till #{@timestamp}"
        end
      end
      File.open(@log_file, 'w') do |f|
        f.puts lines
      end
      up
    end

    def is_up_dig? ip=nil
      ip = @ip if ip.nil?
      dig = `dig +time=1 +tries=1 #{ip}`
      dig.lines.find {|l| l =~ /time.*ms/}
    end

    def is_up_wget host=nil
      host = @host if host.nil?
      wget = `wget -t 1 --timeout 1 --spider #{host}`
      return $?.exitstatus
    end

    def ensure_logfile
      return if File.exist? @log_file
      append_to_logfile "# This file is created by the downtime #{Downtime::VERSION} ruby gem."
    end

    def timestamp!
      @timestamp = Timestamp.new
    end

    def append_to_logfile text
      File.open(@log_file, 'a') do |f|
        f.puts text
      end
    end
  end
end
