require 'date'

module Downtime
  class Timestamp
    @@time_pattern = "%Y-%m-%d-%H-%M"
    @@time_pattern_zone = "%Y-%m-%d-%H-%M %Z"
    attr_accessor :datetime

    def self.time_pattern
      @@time_pattern
    end

    def initialize time=DateTime.now
      @datetime = time
    end

    def to_s
      @datetime.strftime @@time_pattern
    end

    ## Will create CET times.
    def self.from_s string
      Timestamp.new(DateTime.strptime string + " CET", @@time_pattern_zone)
    end

    # Returns difference to other timestamp in minutes.
    def -(other_timestamp)
      ((@datetime.to_time - other_timestamp.datetime.to_time) / 60.0).to_i
    end
  end
end
