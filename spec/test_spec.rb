require 'English'
require 'tmpdir'

RSpec.describe 'Process#wait' do
  it 'should set the global $CHILD_STATUS variable' do
    pid = Process.spawn('ruby', 'bin/command-line-test')
    Process.wait(pid)
    expect($CHILD_STATUS).not_to be_nil
    expect($CHILD_STATUS.pid).to eq(pid)
  end
end

RSpec.describe 'Process#wait2' do
  it 'should return a non-nil status' do
    pid = Process.spawn('ruby', 'bin/command-line-test')
    exited_pid, status = Process.wait2(pid)
    expect(status).not_to be_nil
    expect(status.pid).to eq(pid)
  end
end

RSpec.describe 'Process.spawn chdir: option' do
  let(:script_path) { File.expand_path('bin/command-line-test') }

  context 'with an invalid directory' do
    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          example.run
        end
      end
    end

    it 'raises an error' do
      expect {
        Process.spawn('ruby', script_path, chdir: 'invalid/directory')
      }.to raise_error(Errno::ENOENT)
    end
  end
end
