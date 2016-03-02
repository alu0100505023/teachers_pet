require 'require_all'
require 'json'
require_rel '.'



class Interface
  attr_reader :option
  attr_accessor :config
  attr_accessor :client
  attr_accessor :deep

  def initialize
  end


  def load_config
    json = File.read('./lib/configure/configure.json')
    config=JSON.parse(json)

    if config["User"] == nil
      return false
    else
      @config=config
      @deep=1
      return true
    end
  end

  def login(username,password,token)
    @client = Octokit::Client.new(:login=>username, :password=>password, :token =>token)
    #puts @client.login
    #puts @client.organizations(@config["User"]).url
  ##  puts repo

    #puts client.password
    # opts=TeachersPet::Actions::Base.new.init_client_bash(username,password,token)
    # puts opts
    # puts opts.fields
  end

  def prompt()
    case
      when @deep == 1 then return @config["User"]+">"
      when @deep == 2 then return @config["User"]+">"+@config["Org"]+">"
      when @deep == 3 then return @config["User"]+">"+@config["Org"]+">"+@config["Repo"]+">"
    end
  end

  def help()
    case
      when @deep == 1
        puts "\nList of commands.\n"
        print "exit => exit from this program\n"
        print "orgs => show your organizations\n"
        print "ls => list your repositories\n"
        print "cd => go to the path\n"
        print "help => list of commands available\n\n"
      when @deep == 2
        puts "\nList of commands.\n"
        print "exit => exit from this program\n"
        print "ls => list your repositories of your organization\n"
        print "cd => go to the path\n"
        print "help => list of commands available\n\n"
      when @deep == 3
    end
  end

  def ls()
    case
      when @deep == 1
        repo=@client.repositories
        repo.each do |i|
          puts i.name
        end
      when @deep ==2
        repos=@client.organization_repositories(@client["Org"])
        repos.each do |y|
          puts y.name
        end
    end
  end

  def lsl()

  end

  def cdback()
    case
      #when @deep == 1 then @config["User"]=nil
      when @deep == 2
        @config["Org"]=nil
        @deep=1
      when @deep == 3
        @deep=2
    end
  end

  def cd(path)
    case
    when @deep=1
      @config["Org"]=path
      @deep=2
    end
  end

  def orgs()
    case
    when @deep=1
      org=@client.organizations(@config["User"])
      org.each do |i|
        puts i.name
      end
    end
  end

  def run
    ex=1
    if self.load_config == true
      self.login(@config["User"],@config["Pass"], @config["Token"])

      while ex != 0
        print self.prompt()
        STDOUT.flush
        op = gets.chomp
        opcd=op.split
        case
          when op == "exit" then ex=0
          when op == "help" then self.help()
          when op == "ls" then self.ls()
          when op == "ls -l" then self.lsl()
          when op == "orgs" then self.orgs()
        end
        if opcd[0]=="cd" and opcd[1]!=".."
          self.cd(opcd[1])
        #else
        #  self.cdback()
        end
      end
    else
      puts "User: "
      user = gets.chomp
      puts "Pass: "
      pass = gets.chomp
      puts "Token: "
      token = gets.chomp
      self.login(user,pass,token)
    end

    js=File.open('./lib/configure/configure2.json','w')
    js.write(@config.to_json)
    puts @config
  end

end

inp = Interface.new
inp.load_config
inp.run
#inp.login(inp.config["User"],inp.config["Pass"], inp.config["Token"])
