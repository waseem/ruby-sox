module Sox
  # Provides methods to run command in /bin/sh and /bin/bash interpreters.
  # Usual `system` method runs /bin/sh which doesn't support process substitution
  # feature. So sometime we need to use bash with process substitution in order
  # to avoid disk IO operations.
  #
  # Also this module takes care of error handling and raises {Sox::Error} in case of
  # failure message returned by shell command.
  #
  # See http://en.wikipedia.org/wiki/Process_substitution
  module Shell
    # Path to bash interpreter
    BASH_PATH = '/bin/bash'

    # Run shell command.
    #
    # @param command [String] shell command to execute
    #
    # @return [Boolean] true in case of success
    def sh(command)
      _, _, err_io, thread = Open3.popen3(command)
      thread.join

      process_status = thread.value
      if process_status.success?
        true
      else
        raise Error, err_io.read
      end
    rescue Errno::ENOENT => err
      msg = "#{err.message}. Do you have `#{SOX_COMMAND}' installed?"
      raise Error, msg
    end

    # Run bash command.
    #
    # @param command [String] bash command to execute
    #
    # @return [Boolean] true in case of success
    def bash(command)
      bash_command = "#{BASH_PATH} -c #{Shellwords.escape(command)}"
      sh(bash_command)
    end
  end
end
