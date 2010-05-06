require 'albacore/support/failure'

module RunCommand
  extend AttrMethods
  include Failure
  
  attr_accessor :path_to_command, :require_valid_command, :command_directory
  attr_array :parameters
  
  def initialize
    @require_valid_command = true
    @command_directory = Dir.pwd
    @parameters = []
    super()
  end

  def query(command)
    `#{command}`
  end

  def just_run(command)
    system command 
  end

  def run_command(command_name="Command Line", command_parameters=nil, q=false)
    if @require_valid_command
      return false unless valid_command_exists
    end

    @parameters = @parameters.push(command_parameters) unless command_parameters.nil?
    
    command = "\"#{@path_to_command}\" #{@parameters.join(' ')}"
    @logger.debug "Executing #{command_name}: #{command}"
    
    set_working_directory    
    result = just_run(command) unless q
    result = query(command) if q

    reset_working_directory
    
    result
  end
  
  def valid_command_exists
    return true if File.exist?(@path_to_command || "")
    msg = "Command not found: #{@path_to_command}"
    @logger.fatal msg
  end
  
  def set_working_directory
    @original_directory = Dir.pwd
    return if @command_directory == @original_directory
    Dir.chdir(@command_directory)
  end
  
  def reset_working_directory
    return if Dir.pwd == @original_directory
    Dir.chdir(@original_directory)
  end
end
