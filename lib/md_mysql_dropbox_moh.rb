# md_mysql_dropbox_moh.rb
require 'mysql'
require 'dropbox_sdk'
class BackupData
  attr_accessor :url,:database,:user,:pass
  def initialize
  	print "Server Url :"
  	@url = gets.chomp  
  	print "Database :"
  	@database = gets.chomp 
  	print "User Name :"
  	@user = gets.chomp 
  	print "Password :"
  	@pass = gets.chomp
  	@data = ""
  	@con = Mysql.new @url, @user, @pass, @database
  	puts @con.get_server_info
  	
  	#APP_KEY = zwqkeyv3e3fo410
    #APP_SECRET = 9i74k9tdemp8vng

    flow = DropboxOAuth2FlowNoRedirect.new('zwqkeyv3e3fo410', '9i74k9tdemp8vng')

    authorize_url = flow.start()
    puts '1. Go to: ' + authorize_url
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip    
    access_token, user_id = flow.finish(code)

    @client = DropboxClient.new(access_token)  
  	run_threads   
  end
  def fetch_data
    i=0
    while i<=3
      @data = ""
      puts "#{@url}"
      puts "Fetched at: #{Time.now}"
      result = @con.query("SHOW TABLES")
  	  n_rows = result.num_rows
  	  n_rows.times do
          table= result.fetch_row.join("\s")
          @data= "#{@data} Table : #{table}"
          res = @con.query("DESC #{table}")
          res.each_hash do |row|
             @data =@data + row['Field']             
          end 
          res = @con.query("SELECT * FROM #{table}")
          in_rows = res.num_rows
          in_rows.times do
             @data = @data +" "+ res.fetch_row.join("\s")
             
          end
      end
      puts @data
      sleep(10)
      i=i+1
    end
  end
  def update_dropbox
    j=0
    while j<=2      
      puts "linked account:", 
      File.open("temp.txt", "w") { |io| io.write(@data) }
      file = open('temp.txt')
      #puts @client.metadata('/')['size']
      if @client.search('/', 'database.txt', file_limit=1000, include_deleted=false).length >0
      #if @client.get_file('/database.txt').exist? do
        @client.file_delete('/database.txt')
      end
      response = @client.put_file('/database.txt', file)
      puts "uploaded:"
      puts "Updated at: #{Time.now}"
      sleep(9)
      j=j+1
    end
  end
  def run_threads
  	puts "Started At #{Time.now}"
    t1=Thread.new{fetch_data()}
    t2=Thread.new{update_dropbox()}
    t1.join
    t2.join
    puts "End at #{Time.now}"
    @con.close if @con
  end
end

BackupData.new