require 'spec_helper'

describe 'StubbedEnv' do
  include Rspec::Bash
  let(:subject) { Rspec::Bash::StubbedEnv.new }

  context '#execute_inline' do
    context 'with a stubbed function' do
      before(:each) do
        @overridden_function = subject.stub_command('overridden_function')
        @overridden_command = subject.stub_command('overridden_command')
        @overridden_function.outputs('i was overridden')
      end

      context 'and no arguments' do
        before(:each) do
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          @stdout, @stderr, @status = subject.execute_inline(
            <<-multiline_script
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
          expect(@stderr).to eql("standard error output\n")
        end
      end

      context 'and a path' do
        context 'relative path' do
          before(:each) do
            @overridden_path_function =
              subject.stub_command('relative/path/to/overridden_path_functions')
            @overridden_path_function.outputs('i was overridden in a path')

            @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              'relative/path/to/overridden_path_functions'
            )
          end

          it 'calls the relative path stubbed function' do
            expect(@overridden_path_function).to be_called
          end

          it 'prints the relative path overridden output' do
            expect(@stdout).to eql('i was overridden in a path')
          end
        end
        context 'absolute path' do
          before(:each) do
            @overridden_path_function =
              subject.stub_command('/absolute/path/to/overridden_path_functions')
            @overridden_path_function.outputs('i was overridden in a path')

            @stdout, @stderr, @status = subject.execute_function(
              './spec/scripts/function_library.sh',
              '/absolute/path/to/overridden_path_functions'
            )
          end

          it 'calls the stubbed function' do
            expect(@overridden_path_function).to be_called
          end

          it 'prints the overridden output' do
            expect(@stdout).to eql('i was overridden in a path')
          end
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

  describe 'creating a stubbed env' do
    it 'creates a folder to place the stubbed commands in' do
      env = create_stubbed_env
      expect(Pathname.new(env.dir)).to exist
      expect(Pathname.new(env.dir)).to be_directory
    end
  end

  describe '#cleanup' do
    it 'removes the folder with stubbed commands' do
      env = create_stubbed_env
      env.cleanup
      expect(Pathname.new(env.dir)).not_to exist
    end
  end

  context('stub server') do
    let(:server_thread) { double(Thread) }
    let(:tcp_server) do
      tcp_server = double(TCPServer)
      allow(TCPServer).to receive(:new)
        .with('localhost', 0)
        .and_return(tcp_server)
      tcp_server
    end
    let(:log_manager) do
      log_manager = double(Rspec::Bash::CallLogManager)
      allow(Rspec::Bash::CallLogManager).to receive(:new)
        .and_return(log_manager)
      log_manager
    end
    let(:conf_manager) do
      conf_manager = double(Rspec::Bash::CallConfigurationManager)
      allow(Rspec::Bash::CallConfigurationManager).to receive(:new)
        .and_return(conf_manager)
      conf_manager
    end
    let(:stub_server) do
      stub_server = double(Rspec::Bash::StubServer)
      allow(stub_server).to receive(:start)
        .and_return(server_thread)
      allow(Rspec::Bash::StubServer).to receive(:new)
        .with(log_manager, conf_manager)
        .and_return(stub_server)
      stub_server
    end
    context('#initialize') do
      it 'creates and starts a StubServer' do
        allow(server_thread).to receive(:kill)

        expect(stub_server).to receive(:start)
          .with(tcp_server)

        Rspec::Bash::StubbedEnv.new
      end
    end
  end
end
