# frozen_string_literal: true

module RuboCop
  module Rubycw
    module WarningCapturer
      if defined?(RubyVM::AbstractSyntaxTree)
        require 'stringio'

        module ::Warning
          def warn(*message)
            if WarningCapturer.warnings
              WarningCapturer.warnings.concat message
            else
              super
            end
          end
        end

        def self.capture(source)
          start
          RubyVM::AbstractSyntaxTree.parse(source)
          warnings.tap do
            stop
          end
        end

        def self.start
          @warnings = []
        end

        def self.stop
          @warnings = nil
        end

        def self.warnings
          @warnings
        end

        stop
      else
        require 'rbconfig'
        require 'open3'

        def self.capture(source)
          _stdout, stderr, _status = Open3.capture3(RbConfig.ruby, '-cw', '-e', source)
          stderr.lines.map(&:chomp)
        end
      end
    end
  end
end
