#
# A fun example of using 0MQ sockets to communicate between processes.
# 

require 'zmq'

class Boss
  def initialize
    @context = ZMQ::Context.new

    @somebody_socket = @context.socket ZMQ::PUSH
    @somebody_socket.bind "ipc://boss:pushpull"

    @everybody_socket = @context.socket ZMQ::PUB
    @everybody_socket.bind "ipc://boss:pubsub"
  end

  def boss_around
    puts "Shut up, I'm the boss."
    loop do
      print "Ready to boss: "
      dispatch gets.chomp
    end
  end

  private
    def dispatch msg
      if msg =~ /somebody/
        msg = msg.sub('somebody ', '')
        @somebody_socket.send msg
        puts "Done sending #{msg} to somebody."
      else
        msg = msg.sub('everybody ', '')
        @everybody_socket.send msg
        puts "Done sending #{msg} to everybody."
      end
    end

    def somebody msg
      @somebody_socket.send msg
    end

    def everyone msg
    end
end

class Worker
  def initialize
    @context = ZMQ::Context.new

    @hr_socket = @context.socket ZMQ::PUSH
    @hr_socket.connect "ipc://hr:pushpull"

    @just_me_socket = @context.socket ZMQ::PULL
    @just_me_socket.connect "ipc://boss:pushpull"

    @all_of_us_socket = @context.socket ZMQ::SUB
    @all_of_us_socket.setsockopt ZMQ::SUBSCRIBE, ""
    @all_of_us_socket.connect "ipc://boss:pubsub"
  end

  def start_working
    puts "Ready to work!"

    just_me_thread = Thread.new do
      loop do
        just_me_msg = @just_me_socket.recv
        unless just_me_msg.empty?
          report_to_hr just_me_msg
          send just_me_msg 
        end
      end
    end

    group_thread = Thread.new do
      loop do
        all_of_us_msg = @all_of_us_socket.recv
        unless all_of_us_msg.empty?
          report_to_hr all_of_us_msg
          send all_of_us_msg
        end
      end
    end

    just_me_thread.join
    group_thread.join
  end

  def report_to_hr msg
    @hr_socket.send "Worker #{object_id} was told to #{msg}"
  end

  def jump
    puts "How high, sir?"
  end

  def do_something_complicated
    puts "This'll be easy!"
    sleep 1
    puts "..."
    sleep 1
    puts "My brain hurts :("
  end

  def get_fired
    puts "But I've got kids to feed!"
    exit!
  end

  private
    def method_missing m, *args, &block
      puts "Sorry boss, I don't know how to #{m} :/"
    end
end

class HRPerson
  def initialize
    @context = ZMQ::Context.new
    @reports_socket = @context.socket ZMQ::PULL
    @reports_socket.bind "ipc://hr:pushpull"
    
    accept_reports
  end

  def accept_reports
    puts "Ready to log some reports!"
    loop do
      report = @reports_socket.recv
      log report
    end
  end

  def log report
    puts report
  end
end
