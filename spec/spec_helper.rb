# frozen_string_literal: true

require 'English'
require 'rspec'
require 'tempfile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Platform
def windows? = Gem.win_platform?
def mac? =RUBY_PLATFORM.include?('darwin')

# Engine
def truffleruby? = RUBY_ENGINE == 'truffleruby'
def jruby? = RUBY_ENGINE == 'jruby'
def mri? = RUBY_ENGINE == 'ruby'

def ci_build? = ENV.fetch('GITHUB_ACTIONS', 'false') == 'true'

# Chdir to a temporary directory and yield to the given block
#
# The temporary directory will be removed after the block is executed.
#
# @yield The block to execute in the temporary directory
# @yieldparam dir [String] The path to the temporary directory
#
# @return [Object] The return value of the given block
#
# @example
#   in_temp_dir do
#     puts Dir.pwd #=> /path/to/temp/dir
#   end
#
def in_temp_dir(&block)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir, &block)
  end
end

# Chdir to the given relative path and yield to the given block
#
# If the directory does not exist, it (and all intermediate directories) will be created.
#
# @param relative_path [String] The relative path to chdir to
# @yield The block to execute in the chdir'd directory
#
# @example
#   in_dir('foo/bar') do
#     puts Dir.pwd #=> /path/to/current/dir/foo/bar
#   end
#
def in_dir(relative_path, &)
  FileUtils.mkdir_p(relative_path)
  Dir.chdir(relative_path, &)
end

class String
  # Replace Windows style EOL (\r\n) with Unix style (\n)
  # Replace any remaining Mac style EOL (\r) with Unix style (\n)
  def with_linux_eol
    gsub("\r\n", "\n").gsub("\r", "\n")
  end
end

def eol = windows? ? "\r\n" : "\n"
