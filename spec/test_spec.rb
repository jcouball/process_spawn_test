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
  # Execute tests in a temporary directory
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  # The value of subject will be a Process::Status
  subject do
    pid = Process.spawn('ruby', script_path, chdir: chdir_path)
    _pid, status = Process.wait2(pid)
    status
  end

  # Since we chdir in the test, make sure the path to the script is absolute
  let(:script_path) { File.expand_path('../bin/command-line-test', __dir__) }

  context 'with an invalid directory' do
    let(:chdir_path) { 'does_not_exist' }

    it 'should raise ERRNO::ENOENT' do
      expect { subject }.to raise_error(Errno::ENOENT)
    end

    context 'on truffleruby', if: truffleruby? do
      it 'incorrectly returns a non-zero exitstatus without raising an error' do
        expect(subject).to have_attributes(exitstatus: 1)
      end
    end
  end

  context 'with a path to a file' do
    let(:chdir_path) { 'file1.txt' }

    before do
      File.write(chdir_path, 'contents')
    end

    it 'should raise Errno::ENOTDIR' do
      # Annoyingly, the error raised is different on MRI Windows
      expected_error = windows? ? Errno::EINVAL : Errno::ENOTDIR
      expect { subject }.to raise_error(expected_error)
    end

    context 'on truffleruby', if: truffleruby? do
      it 'incorrectly returns a non-zero exitstatus without raising an error' do
        expect(subject).to have_attributes(exitstatus: 1)
      end
    end
  end
end
