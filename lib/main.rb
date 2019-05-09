#!/usr/bin/env ruby
# The format of TODO_FILE
# {content of todo},{0(uncompleted) or 1(completed)},{level}
# level: 0 is root. level of subtodos starts from 1.

require 'csv'

TODO_FILE = "#{ENV['HOME']}/.todo".freeze
COMPLETED = 1
UNCOMPLETED = 0

def count_file_lines(file_name)
  File.readlines(file_name).size
end

def overwrite_todo
  # Assign an array of todos to a block variable.
  todos = CSV.readlines(TODO_FILE)
  todos.shift
  yield(todos)
  CSV.open(TODO_FILE, 'w') do |csv|
    csv << %w[content status level]
    todos.each do |todo|
      csv << todo
    end
  end
end

def show_help
  # print <<~EOF
  # Usage: todo COMMAND ARGUMENTS
  #  add     TODO:        Add a todo.
  #  check   NUMBER:      Mark a todo as completed.
  #  uncheck NUMBER:      Mark a todo as incompleted.
  #  change  NUMBER TODO: Change a todo.
  #  delete  NUMBER:      Delete a todo.
  #  delete_completed:    Delete all completed todos.
  #  subtodo NUMBER TODO: Add a subtodo.
  #  show:                Show todos.
  #  help:                Show this message.
  # EOF
end

def valid_index?(todo_index)
  if todo_index <= 0
    warn 'Todo index must be positive.'
    return false
  end

  if todo_index > count_file_lines(TODO_FILE) - 1
    warn "Todo index #{todo_index}: Out of range."
    return false
  end
  true
end

def add_todo(todo_content)
  if todo_content.nil?
    show_help
    return 1
  end

  CSV.open(TODO_FILE, 'a') do |csv|
    csv << [todo_content, 0, 0]
  end
end

def change_todo_process(todo_index, todo_status)
  # todo_status is either COMPLETED or UNCOMPLETED.

  return unless valid_index?(todo_index)

  # read all lines, check the specified todo, then join all todos and write it to TODO file.
  overwrite_todo do |todos|
    # mark the specified todo as COMPLETED or UNCOMPLETED.
    todos[todo_index - 1][1] = todo_status
  end
end

def check_todo(todo_index)
  change_todo_process(todo_index, COMPLETED)
end

def uncheck_todo(todo_index)
  change_todo_process(todo_index, UNCOMPLETED)
end

def show_todos
  # To arrange vertical line of the indexes, calculate digits.
  digit_number = Math.log10(count_file_lines(TODO_FILE)) + 1
  CSV.foreach(TODO_FILE, headers: true) do |todo|
    print "#{($INPUT_LINE_NUMBER - 1).to_s.rjust(digit_number)}: "  # -1 is needed because $INPUT_LINE_NUMBER counts header as 1.
    print '-' * todo['level'].to_i + '> ' if todo['level'].to_i > 0 # subtodo arrow

    # For some reasons, RED='\e[31m';print "#{RED}" will print \e[31m itself.
    # \e[31m is red, \e[32m is green. \e[0m will reset colors.
    print todo['status'].to_i == UNCOMPLETED ? "\e[31m" : "\e[32m"
    puts "#{todo['content']}\e[0m"
  end
end

def delete_todo(todo_index)
  return unless valid_index?(todo_index)

  overwrite_todo do |todos|
    todos.delete_at(todo_index - 1)
  end
end

def delete_all_completed_todo
  overwrite_todo do |todos|
    todos.delete_if do |todo|
      todo_status = todo[1].to_i
      todo_status == COMPLETED
    end
  end
end

def main
  if !File.exist?(TODO_FILE) || (File.size(TODO_FILE) == 0)
    File.open(TODO_FILE, 'w') do |file|
      file.write("content,status,level\n")
    end
  end

  case ARGV[0]
  when 'add'
    add_todo(ARGV[1])
  when 'check'
    check_todo(ARGV[1].to_i)
  when 'uncheck'
    uncheck_todo(ARGV[1].to_i)
  when 'show'
    show_todos
  when 'delete'
    delete_todo(ARGV[1].to_i)
  when 'delete_completed'
    delete_all_completed_todo
  else
    show_help
  end
end

main
