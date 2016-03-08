require 'require_all'
require 'json'
require_rel '.'
require 'readline'


class Interface
  attr_reader :option
  attr_accessor :config
  attr_accessor :client
  attr_accessor :deep
  LIST = ['repos', 'exit', 'orgs','help', 'members','teams', 'cd ', 'commits','forks'].sort

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
  end

  def prompt()
    case
      when @deep == 1 then return @config["User"]+"> "
      when @deep == 10 then return @config["User"]+">"+@config["Repo"]+"> "
      when @deep == 2 then return @config["User"]+">"+@config["Org"]+"> "
      when @deep == 3 then return @config["User"]+">"+@config["Org"]+">"+@config["Repo"]+"> "
    end
  end

  def help()
    case
      when @deep == 1
        HelpM.new.user()
      when @deep == 2
        HelpM.new.org()
      when @deep == 3
        HelpM.new.org_repo()
      when @deep == 10
        HelpM.new.user_repo()
    end
  end

  def ls()
    memory=[]
    case
      when @deep == 1
        print "\n"
        repo=@client.repositories
        repo.each do |i|
          puts i.name
          memory.push(i.name)
        end
      when @deep ==2
        #puts @config["Org"]
        print "\n"
        repos=@client.organization_repositories(@config["Org"])
        repos.each do |y|
          puts y.name
          memory.push(y.name)
        end
    end
    history=LIST+memory
    comp = proc { |s| history.grep( /^#{Regexp.escape(s)}/ ) }
    Readline.completion_append_character = ""
    Readline.completion_proc = comp
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
        @config["Repo"]=nil
        @deep=2
      when @deep == 10
        @config["Repo"]=nil
        @deep=1
    end
  end

  def cd(path)
    case
    when @deep==1
      @config["Org"]=path
      @deep=2
    when @deep==2
      @config["Repo"]=path
      @deep=3
    end
  end

  def orgs()
    case
    when @deep==1
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
    when @deep==2
      print "\n"
      mem=@client.organization_members(@config["Org"])
      mem.each do |i|
        m=eval(i.inspect)
        puts m[:login]
      end
    end
    print "\n"
  end

  def commits()
    print "\n"
    case
    when @deep==3
      mem=@client.commits(@config["Org"]+"/"+@config["Repo"],"master")
      mem.each do |i|
        #puts i.inspect
        print i[:sha],"\n",i[:commit][:author][:name],"\n",i[:commit][:author][:date],"\n",i[:commit][:message],"\n\n"
        #m=eval(i.inspect)
      end
    end
    print "\n"
  end

  def show_forks()
    print "\n"
    case
    when @deep==3
      mem=@client.forks(@config["Org"]+"/"+@config["Repo"])
      mem.each do |i|
        puts i[:owner][:login]
      end
    end
    print "\n"
  end

  def collaborators()
    print "\n"
    case
    when @deep==3
      mem=@client.collaborators(@config["Org"]+"/"+@config["Repo"])
      mem.each do |i|
        #puts i.name
        puts i[:author][:login]
        #m=eval(i.inspect)
      end
    end
    print "\n"
  end

  def teams()
    case
    when @deep==2
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
    memory=['Prueba']
    history=LIST+memory
    #comp = proc { |s| LIST.grep( /^#{Regexp.escape(s)}/ ) }
    comp = proc { |s| LIST.grep( /^#{Regexp.escape(s)}/ ) }

    Readline.completion_append_character = ""
    Readline.completion_proc = comp

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
          when op == "commits" then self.commits()
          when op == "col" then self.collaborators()
          when op == "forks" then self.show_forks()
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

    File.write('./lib/configure/configure.json',@config.to_json)
  end

end

inp = Interface.new
inp.load_config
inp.run
