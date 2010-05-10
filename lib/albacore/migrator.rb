require 'albacore/support/albacore_helper'
require 'albacore/sqlcmd'

class Migrator < SQLCmd
  attr_accessor :migration_directory, :migration_table_name 

  def initialize(&block)
    block.call self unless block.nil? 
    super
    @migration_table_name = "albacore_migrations" if migration_table_name.nil?
  end

  def last_run
    @query = "SELECT MAX(ID) FROM albacore_migrations"
    run 
    scalar result
  end

  def migrate
    insure_migration_table_exists
    pending.each do |m|
      @query = nil
      @scripts = [full_path(m)]
      @parameters = []
      run      

      puts "Executing #{m}..."
      @parameters = []
      @scripts = []
      @query = "INSERT INTO #{migration_table_name} (ID) VALUES (#{migration_number(m)})"
      run
    end
  end

  def full_path(file_name)
    migration_directory + "/" + file_name
  end

  def all_migrations
    if migration_directory.nil?
      raise ArgumentError, "Migration Directory was not supplied" 
    end
    Dir.entries(migration_directory).find_all {|f| f.match('.sql') }
  end

  def pending
    all_migrations.find_all {|m| migration_number(m) > self.last_run}
  end

  private
  
  def scalar(sql_result)
    raise "No results returned from query: '#{@query}'" if sql_result.nil?
    sql_result.match('--\s+(\d+)').captures.first.to_i
  end

  def insure_migration_table_exists
    create_migration_table unless migration_table_exists?
  end

  def migration_table_exists?
    execute_sql "SELECT count(1) FROM sysobjects WHERE NAME = '#{migration_table_name}'"    
    scalar(result) > 0 
  end

  def create_migration_table
    execute_sql "CREATE TABLE #{migration_table_name} (ID int NULL, CreateDate datetime NOT NULL DEFAULT(getdate())); INSERT INTO  #{migration_table_name} (ID) VALUES(0)" 
  end

  def execute_sql(sql)    
    @query = sql
    run
  end
  
  def migration_number(filename)
    match = filename.match '(\d+)_'
    match.captures.first.to_i
  end

end

