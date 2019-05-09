# The format of TODO_FILE
# {content of todo},{0(uncompleted) or 1(completed)},{level}
# level: 0 is root. level of subtodos starts from 1.

TODO_FILE = "#{ENV['HOME']}/.todo".freeze
COMPLETED = 1
UNCOMPLETED = 0

def count_file_lines(file_name)
  File.open(file_name) do |file|
    while file.gets; end
    return file.lineno
  end
end

def overwrite_todo
  # Assign an array of todos to a block variable.
  todos = File.readlines(TODO_FILE)
  yield(todos)
  File.open(TODO_FILE, 'w').write(todos.join)
end

def show_help
  #  print <<EOF
  # Usage: todo COMMAND ARGUMENTS
  #   add     TODO:        Add a todo.
  #   check   NUMBER:      Mark a todo as completed.
  #   uncheck NUMBER:      Mark a todo as incompleted.
  #   change  NUMBER TODO: Change a todo.
  #   delete  NUMBER:      Delete a todo.
  #   subtodo NUMBER TODO: Add a subtodo.
  #   show:                Show todos.
  #   help:                Show this message.
  # EOF
end

def show_message_if_index_not_positive(todo_index)
  # Return True if index is not positive, otherwise return False.
  if todo_index <= 0
    STDERR.puts 'Todo index should be positive number.'
    return true
  end
  false
end

def add_todo(todo)
  if todo.nil?
    show_help
    return 1
  end

  File.open(TODO_FILE, 'a').puts("#{todo},0,0")
end

def change_todo_process(todo_index, process_number)
  # process_number is either COMPLETED or UNCOMPLETED.

  todo_index = todo_index.to_i
  return if show_message_if_index_not_positive(todo_index)

  # read all lines, check the specified todo, then join all todos and write it to TODO file.
  overwrite_todo do |todos|
    # mark the specified todo as COMPLETED or UNCOMPLETED.
    todos[todo_index - 1].gsub!(/(.+),[01],([0-9]+)/) { "#{Regexp.last_match(1)},#{process_number},#{Regexp.last_match(2)}" }
  end
end

def check_todo(todo_index)
  change_todo_process(todo_index, COMPLETED)
end

def uncheck_todo(todo_index)
  change_todo_process(todo_index, UNCOMPLETED)
end

def show_todos
  return 1 unless File.exist?(TODO_FILE)
  return 1 if File.size(TODO_FILE) == 0

  # To arrange vertical line of the indexes, calculate digits.
  digit_number = Math.log10(count_file_lines(TODO_FILE)) + 1
  File.open(TODO_FILE) do |file|
    file.each_line do |line|
      todo_content, todo_status, todo_level = line.match(/(.+),([01]),([0-9]+)/)[1..3]
      todo_level = todo_level.to_i
      todo_status = todo_status.to_i

      print "#{file.lineno.to_s.rjust(digit_number)}: "
      print '-' * todo_level + '> ' if todo_level > 0 # subtodo arrow

      # For some reasons, RED='\e[31m';print "#{RED}" will print \e[31m itself.
      # \e[31m is red, \e[32m is green.
      print todo_status == UNCOMPLETED ? "\e[31m" : "\e[32m"
      puts "#{todo_content}\e[0m"
    end
  end
end

def delete_todo(todo_index)
  todo_index = todo_index.to_i

  return if show_message_if_index_not_positive(todo_index)

  overwrite_todo do |todos|
    todos.delete_at(todo_index - 1)
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
  when 'delete'
    delete_todo(ARGV[1])
  else
    show_help
  end
end

main
