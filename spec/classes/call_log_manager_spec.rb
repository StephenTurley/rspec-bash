require 'spec_helper'
include Rspec::Bash

describe 'CallLogManager' do
  include_examples 'manage a :temp_directory'

  let(:subject) {CallLogManager.new}

  context('#add_log') do
    it('passes the logs to their respective calllogs') do
      first_command_call_log  = double(CallLog)
      second_command_call_log = double(CallLog)

      allow(CallLog).to receive(:new).with('first_command')
        .and_return(first_command_call_log).once
      allow(CallLog).to receive(:new).with('second_command')
        .and_return(second_command_call_log).once
      expect(first_command_call_log).to receive(:add_log)
        .with('stdin', %w(first_argument second_argument)).twice
      expect(second_command_call_log).to receive(:add_log)
        .with('stdin', %w(first_argument second_argument)).twice
      subject.add_log('first_command', 'stdin', %w(first_argument second_argument))
      subject.add_log('first_command', 'stdin', %w(first_argument second_argument))
      subject.add_log('second_command', 'stdin', %w(first_argument second_argument))
      subject.add_log('second_command', 'stdin', %w(first_argument second_argument))
    end
  end
  context('#stdin_for_args') do
    it('gets the respective stdin for an array of arguments') do
      first_command_call_log  = double(CallLog)
      second_command_call_log = double(CallLog)

      allow(CallLog).to receive(:new).with('first_command')
        .and_return(first_command_call_log).once
      allow(CallLog).to receive(:new).with('second_command')
        .and_return(second_command_call_log).once

      allow(first_command_call_log).to receive(:stdin_for_args)
        .with(%w(first_argument second_argument))
        .and_return('first_command stdin for [first_argument, second_argument]')
      allow(first_command_call_log).to receive(:stdin_for_args)
        .with(%w(third_argument fourth_argument))
        .and_return('first_command stdin for [third_argument, fourth_argument]')
      allow(second_command_call_log).to receive(:stdin_for_args)
        .with(%w(first_argument second_argument))
        .and_return('second_command stdin for [first_argument, second_argument]')
      allow(second_command_call_log).to receive(:stdin_for_args)
        .with(%w(third_argument fourth_argument))
        .and_return('second_command stdin for [third_argument, fourth_argument]')

      expect(subject.stdin_for_args('first_command', %w(first_argument second_argument)))
        .to eql('first_command stdin for [first_argument, second_argument]')
      expect(subject.stdin_for_args('first_command', %w(third_argument fourth_argument)))
        .to eql('first_command stdin for [third_argument, fourth_argument]')
      expect(subject.stdin_for_args('second_command', %w(first_argument second_argument)))
        .to eql('second_command stdin for [first_argument, second_argument]')
      expect(subject.stdin_for_args('second_command', %w(third_argument fourth_argument)))
        .to eql('second_command stdin for [third_argument, fourth_argument]')
    end
  end
end


