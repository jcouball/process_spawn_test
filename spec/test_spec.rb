require 'English'

describe 'Process#wait' do
  it 'should set the global $CHILD_STATUS variable' do
    pid = Process.spawn('ruby', 'bin/command-line-test')
    Process.wait(pid)
    expect($CHILD_STATUS).not_to be_nil
    expect($CHILD_STATUS.pid).to eq(pid)
  end
end

describe 'Process#wait2' do
  it 'should return a non-nil status' do
    pid = Process.spawn('ruby', 'bin/command-line-test')
    exited_pid, status = Process.wait2(pid)
    expect(status).not_to be_nil
    expect(status.pid).to eq(pid)
  end
end
