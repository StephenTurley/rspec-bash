require 'English'
require 'rspec/shell/expectations'

describe 'StubbedEnv' do
  include Rspec::Shell::Expectations
  let(:subject) { Rspec::Shell::Expectations::StubbedEnv.new }

  context '#execute_inline' do
    context 'with a stubbed function' do
      before(:each) do
        @overridden_function = subject.stub_command('overridden_function')
        @overridden_command = subject.stub_command('overridden_command')
        @overridden_function.outputs('i was overridden')
      end

      context 'and no arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
            #!/usr/bin/env bash
            function overridden_function {
              echo 'i was not overridden'
            }
            overridden_function

            echo 'standard error output' 1>&2
          multiline_script
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(@stderr).to eql("standard error output\n")
        end
      end

      context 'and simple arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
          #!/usr/bin/env bash
            function overridden_function {
              echo 'i was not overridden'
            }
            overridden_function argument_one argument_two

            echo 'standard error output' 1>&2
          multiline_script
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
          #!/usr/bin/env bash
            function overridden_function {
              echo 'i was not overridden'
            }
            overridden_function "argument one" "argument two"

            echo 'standard error output' 1>&2
          multiline_script
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end
    end
    context 'with a stubbed command' do
      before(:each) do
        @overridden_command = subject.stub_command('overridden_command')
        @overridden_function = subject.stub_command('overridden_function')
        @overridden_command.outputs('i was overridden')
      end

      context 'and no arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
            #!/usr/bin/env bash
            overridden_command
          multiline_script
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end

      context 'and simple arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
            #!/usr/bin/env bash
            overridden_command argument_one argument_two
          multiline_script
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(<<-multiline_script
            #!/usr/bin/env bash
            overridden_command "argument one" "argument two"
          multiline_script
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end
    end
  end

  context '#execute_function' do
    context 'with a stubbed function' do
      before(:each) do
        @overridden_function = subject.stub_command('overridden_function')
        @overridden_command = subject.stub_command('overridden_command')
        @overridden_function.outputs('i was overridden')
        @overridden_function.outputs('standard error output', to: :stderr)
      end

      context 'and no arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_function'
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(@stderr).to eql('standard error output')
        end
      end

      context 'and simple arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_function argument_one argument_two'
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_function "argument one" "argument two"'
          )
        end

        it 'calls the stubbed function' do
          expect(@overridden_function).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end
    end
    context 'with a stubbed command' do
      before(:each) do
        @overridden_function = subject.stub_command('overridden_function')
        @overridden_command = subject.stub_command('overridden_command')
        @overridden_command.outputs('i was overridden')
      end

      context 'and no arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_command_function'
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(@stderr).to eql("standard error output\n")
        end
      end

      context 'and simple arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_command_function argument_one argument_two'
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'overridden_command_function "argument one" "argument two"'
          )
        end

        it 'calls the stubbed command' do
          expect(@overridden_command).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(@stdout).to eql('i was overridden')
        end
      end
    end
  end
end