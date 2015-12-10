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
      @log_file_dig = "downtime_dig.log"
      @log_file_wget = "downtime_wget.log"
    end

    def perform
      ensure_logfiles
      timestamp!
      check_and_update_files
    end

    private

    def check_and_update_files
      check_and_update_file(@log_file_dig, &method(:is_up_dig?))
      check_and_update_file(@log_file_wget, &method(:is_up_wget?))
    end

    def check_and_update_file(log_file, &check_mthd)
      lines = File.readlines log_file
      was_down = lines[-1] =~ /down/
      up = check_mthd.call
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
      File.open(log_file, 'w') do |f|
        f.puts lines
      end
      up
    end

    def is_up_dig? ip=nil
      ip = @ip if ip.nil?
      dig = `dig +time=1 +tries=1 #{ip}`
      dig.lines.find {|l| l =~ /time.*ms/}
    end

    def is_up_wget? host=nil
      host = @host if host.nil?
      wget = `wget -q -t 1 --timeout 1 --spider #{host}`
      return $?.exitstatus
    end

    def ensure_logfiles
      return if(File.exist?(@log_file_dig) && File.exist?(@log_file_wget))
      append_to_logfiles "# This file is created by the downtime #{Downtime::VERSION} ruby gem."
    end

    def timestamp!
      @timestamp = Timestamp.new
    end

    def append_to_logfiles text
      File.open(@log_file_wget, 'a') do |f|
        f.puts text
      end
      File.open(@log_file_dig, 'a') do |f|
        f.puts text
      end
    end
  end
end
