# frozen_string_literal: true

require_relative "tomatos/version"

module Tomatos
  class Error < StandardError; end
end

module Tomatos
  class App
    def initialize(options)
      @title = 'Tomatos Clock'
      @time_delta = options[:time] || '15m'
      @time_value = 0
      @unit = 'm'
      @message = options[:message] || nil
    end

    def notice(content, title = nil, subtitle = nil)
      system("osascript -e 'display notification \"#{content}\" with title \"#{title}\" subtitle \"#{subtitle}\"'")
    end

    def parser_delta_time
      # use secs
      time_delta_secs = 0

      case @time_delta
      when /(\d+)m$/
        time_delta_secs = $1.to_i * 60
        @time_value = $1
        @unit = 'm'
      when /(\d+)s$/
        time_delta_secs = $1.to_i
        @time_value = $1
        @unit = 's'

      when /(\d+)$/
        time_delta_secs = $1.to_i
        @time_value = $1
        @unit = 'm'
      end
    end

    def count_down_text(count_down)
      mins = count_down / 60 % 60
      secs = count_down % 60

      return "#{mins < 10 ? '0' + mins.to_s : mins.to_s} min #{secs < 10 ? '0'+secs.to_s : secs.to_s} sec"
    end

    def run
      self.parser_delta_time
      unit_text = @unit == 'm' ? 'min' : 'sec'
      total_secs = @unit == 'm' ? @time_value.to_i * 60 : @time_value.to_i

      self.notice("Start: #{@time_value} #{unit_text}", @title, @message)
      count_down = total_secs.dup
      while count_down > 0 do
        sleep(1)
        system('clear')
        count_down -= 1
        puts @title
        puts "@time: #{self.count_down_text(count_down)}"
        puts "@message: #{@message}" if @message
      end
      self.notice("#{@time_value} #{unit_text} Finished", @title, @message)
    end
  end
end
