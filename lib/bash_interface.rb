require 'require_all'
require 'json'
require_rel '.'


class Interface
  attr_reader :option
  @config

  def initialize
  end

  def login
    print 'todo'
  end

  def load_config
    json = File.read('./lib/configure/configure.json')
    config=JSON.parse(json)

    if config["User"] == nil
      #puts "Not loged"
      return false
    else
      #puts "Loged"
      #puts config["User"]
      @config=config
      return true
    end
  end

  def prompt(deep)
    case
      when deep == 1 then return @config["User"]+">"
      when deep == 2 then return @config["User"]+">"+@config["Org"]+">"
      when deep == 3 then return @config["User"]+">"+@config["Org"]+">"+@config["Repo"]+">"
    end
  end

  def help(deep)
    case
      when deep == 1
        puts "\nList of commands.\n"
        print "exit => exit from this program\n"
        print "help => list of commands available\n\n"
      when deep == 2
      when deep == 3
    end
  end

  def ls(deep)
  end

  def lsl(deep)
  end

  def run
    ex=1
    deep=1
    if self.load_config == true

      while ex != 0
        print self.prompt(deep)
        STDOUT.flush
        op = gets.chomp

        case
          when op == "exit" then ex=0
          when op == "help" then self.help(deep)
          when op == "ls" then self.ls(deep)
          when op == "ls" then self.lsl(deep)
        end

      end

    end
  end

end
op=Interface.new
op.run
