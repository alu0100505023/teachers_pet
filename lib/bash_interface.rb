require 'require_all'
require 'json'
require_rel '.'
require 'readline'


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
        print "repos => list your repositories\n"
        print "cd => go to the path\n"
        print "help => list of commands available\n\n"
      when @deep == 2
        puts "\nList of commands.\n"
        print "exit => exit from this program\n"
        print "repos => list your repositories of your organization\n"
        print "cd => go to the path\n"
        print "members => members of a organization\n"
        print "teams => teams of a organization\n"
        print "help => list of commands available\n\n"
      when @deep == 3
    end
  end

  def ls()
    case
      when @deep == 1
        print "\n"
        repo=@client.repositories
        repo.each do |i|
          puts i.name
        end
      when @deep ==2
        #puts @config["Org"]
        print "\n"
        repos=@client.organization_repositories(@config["Org"])
        repos.each do |y|
          puts y.name
        end
    end
    print "\n"
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
      print "\n"
      org=@client.organizations
      org.each do |i|
        o=eval(i.inspect)
        puts o[:login]
      end
      print "\n"
    end
  end

  def members()
    case
    when @deep=2
      print "\n"
      mem=@client.organization_members(@config["Org"])
      mem.each do |i|
        m=eval(i.inspect)
        puts m[:login]
      end
    end
    print "\n"
  end

  def teams()
    case
    when @deep=2
      print "\n"
      mem=@client.organization_teams(@config["Org"])
      mem.each do |i|
        puts i.name
      end
    end
    print "\n"
  end

  def run
    ex=1
    if self.load_config == true
      self.login(@config["User"],@config["Pass"], @config["Token"])

      while ex != 0
        op=Readline.readline(self.prompt,true)
        opcd=op.split
        case
          when op == "exit" then ex=0
          when op == "help" then self.help()
          when op == "repos" then self.ls()
          when op == "ls -l" then self.lsl()
          when op == "orgs" then self.orgs()
          when op == "cd .." then self.cdback()
          when op == "members" then self.members()
          when op == "teams" then self.teams()
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
  end

end

inp = Interface.new
inp.load_config
inp.run
#inp.login(inp.config["User"],inp.config["Pass"], inp.config["Token"])
