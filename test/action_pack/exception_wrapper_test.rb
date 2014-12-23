require 'test_helper'

module ActionDispatch
  class ExceptionWrapperTest < ActiveSupport::TestCase
    class TestError < StandardError
      attr_reader :backtrace

      def initialize(*backtrace)
        @backtrace = backtrace
      end
    end

    test '#extract_sources fetches source fragments for every backtrace' do
      exc = TestError.new("/test/controller.rb:9 in 'index'")

      wrapper = ExceptionWrapper.new({}, exc)
      wrapper.expects(:source_fragment).with('/test/controller.rb', 9).returns('some code')

      assert_equal [{
        code: 'some code',
        file: '/test/controller.rb',
        line_number: 9
      }], wrapper.extract_sources
    end

    test '#extract_sources works with Windows paths' do
      exc = TestError.new("c:/path/to/rails/app/controller.rb:27:in 'index':")

      wrapper = ExceptionWrapper.new({}, exc)
      wrapper.expects(:source_fragment).with('c:/path/to/rails/app/controller.rb', 27).returns('nothing')

      assert_equal [{
        code: 'nothing',
        file: 'c:/path/to/rails/app/controller.rb',
        line_number: 27
      }], wrapper.extract_sources
    end

    test '#extract_sources works broken backtrace' do
      exc = TestError.new("invalid")

      wrapper = ExceptionWrapper.new({}, exc)
      wrapper.expects(:source_fragment).with('invalid', 0).returns('nothing')

      assert_equal [{
        code: 'nothing',
        file: 'invalid',
        line_number: 0
      }], wrapper.extract_sources
    end
  end
end
