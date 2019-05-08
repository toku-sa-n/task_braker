# The format of TODO_FILE
# {content of todo},{0(undone) or 1(done)},{level}
# level: 0 is root. level of subtodos starts from 1.

TODO_FILE = "#{ENV['HOME']}/.todo".freeze
DONE = 1
UNDONE = 0

RED = '\e[31m'.freeze
GREEN = '\e[32m'.freeze
RESET_COLOR = '\e[0m'.freeze

def show_help
  #  print <<EOF
  # Usage: todo COMMAND ARGUMENTS
  #   add     TODO:        Add a todo.
  #   check   NUMBER:      Mark a todo as done.
  #   uncheck NUMBER:      Mark a todo as undone.
  #   change  NUMBER TODO: Change a todo.
  #   delete  NUMBER:      Delete a todo.
  #   subtodo NUMBER TODO: Add a subtodo.
  #   show:                Show todos.
  #   help:                Show this message.
  # EOF
end

def add_todo(todo)
  if todo.nil?
    show_help
    return 1
  end

  File.open(TODO_FILE, 'a') do |file|
    file.puts("#{todo},0,0")
  end
end

def change_todo_process(todo_index, process_number)
  # process_number is either 0(undone) or 1(done).

  todo_index_number = todo_index.to_i

  # if todo_index_number is 0, todo_index was an invalid number because to_i converts any non-number to 0.
  if todo_index_number == 0
    show_help
    return 1
  end

  # read all lines, check the specified todo, then join all todos and write it to TODO file.
  todo_lines = File.readlines(TODO_FILE)
  # check or uncheck the specified todo.
  todo_lines[todo_index_number - 1].gsub!(/(\w+),[01],([0-9]+)/) { "#{Regexp.last_match(1)},#{process_number},#{Regexp.last_match(2)}" }
  File.open(TODO_FILE, 'w') do |file|
    file.write(todo_lines.join)
  end
end

def check_todo(todo_index)
  change_todo_process(todo_index, DONE)
end

def uncheck_todo(todo_index)
  change_todo_process(todo_index, UNDONE)
end

def show_todos
  File.open(TODO_FILE) do |file|
    file.each_line do |line|
      todo_content, todo_status = line.match(/(\w+),([01]),[0-9]+/)[1..2]
      if todo_status.to_i == 0
        print "#{RED}#{todo_content}#{RESET_COLOR}\n"
      else
        puts "#{GREEN}#{todo_content}#{RESET_COLOR}"
      end
    end
  end
end

def main
  case ARGV[0]
  when 'add'
    add_todo(ARGV[1])
  when 'check'
    check_todo(ARGV[1])
  when 'uncheck'
    uncheck_todo(ARGV[1])
  when 'show'
    show_todos
  when 'help'
    show_help
  end
end

main
