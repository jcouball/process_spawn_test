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
    _pid, status = Process.wait2(pid)
    expect(status).not_to be_nil
    expect(status.pid).to eq(pid)
  end
end

RSpec.describe 'Process.spawn with a single command argument' do
  it 'should spawn a process via the system shell' do
    pid = Process.spawn('exit 0')
    _pid, status = Process.wait2(pid)
    expect(status).not_to be_nil
    expect(status.exitstatus).to eq(0)
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

    it 'should raise an error' do
      skip "JRuby does not support the chdir: option to Process.spawn" if jruby?
      expect {
        pid = Process.spawn('ruby', script_path, chdir: 'invalid/directory')
        _pid, status = Process.wait2(pid)
        puts status
      }.to raise_error(Errno::ENOENT)
    end
  end
end
