require 'spec_helper'
include Rspec::Bash

describe 'CallArgumentListMatcher' do
  context '#get_call_count' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_list) do
        [
          %w(first_argument second_argument),
          %w(first_argument second_argument third_argument),
          %w(first_argument second_argument)
        ]
      end

      it 'returns the correct count for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 0
      end

      it 'returns the correct count for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 1
      end

      it 'returns the correct count for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 2
      end

      it 'returns the correct count for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 0
      end

      it 'returns the correct count for a no expected argument list' do
        subject = CallArgumentListMatcher.new
        actual_match_count = subject.get_call_count(call_list)
        expect(actual_match_count).to be 3
      end
    end
  end

  context '#get_call_matches' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_list) do
        [
          %w(first_argument second_argument),
          %w(first_argument second_argument third_argument),
          %w(first_argument second_argument)
        ]
      end

      it 'returns the correct calls for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [false, true, false]
      end

      it 'returns true for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [true, false, true]
      end

      it 'returns false for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [false, false, false]
      end

      it 'returns true for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [false, true, false]
      end

      it 'returns true for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [true, false, true]
      end

      it 'returns false for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [false, false, false]
      end

      it 'returns true for no expected argument list' do
        subject = CallArgumentListMatcher.new
        matches = subject.get_call_matches(call_list)
        expect(matches).to eql [true, true, true]
      end
    end
  end

  context '#args_match?' do
    context 'given a call list with a with multiple sets of arguments' do
      let(:call_list) do
        [
          %w(first_argument second_argument),
          %w(first_argument second_argument third_argument),
          %w(first_argument second_argument)
        ]
      end

      it 'returns true for a single exact argument match' do
        argument_list_to_match = %w(first_argument second_argument third_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be true
      end

      it 'returns true for multiple exact argument matches' do
        argument_list_to_match = %w(first_argument second_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be true
      end

      it 'returns false for no argument matches' do
        argument_list_to_match = %w(first_argument)
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be false
      end

      it 'returns true for a single "anything" match' do
        argument_list_to_match = ['first_argument', anything, 'third_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be true
      end

      it 'returns true for multiple "anything" matches' do
        argument_list_to_match = [anything, 'second_argument']
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be true
      end

      it 'returns false for "anything" matches that are not the exact count' do
        argument_list_to_match = [anything, anything, anything, anything]
        subject = CallArgumentListMatcher.new(*argument_list_to_match)
        matches = subject.args_match?(call_list)
        expect(matches).to be false
      end

      it 'returns true for no expected argument list' do
        subject = CallArgumentListMatcher.new
        matches = subject.args_match?(call_list)
        expect(matches).to be true
      end
    end
  end
end