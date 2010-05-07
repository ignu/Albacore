require 'albacore/support/albacore_helper'

class Migrator
  MIGRATION_TABLE_NAME = "albacore_migrations"

  def initialize(cmd)
    @cmd = cmd
    insure_migration_table_exists
  end

  def migration_directory
    File.join(File.dirname(__FILE__), "migrations")
    'c:/code/oss/Albacore/spec/support/migrations'
  end

  def last_run
    @cmd.query = "SELECT MAX(ID) FROM albacore_migrations"
    @cmd.run    
    scalar @cmd.result
  end

  def run
    pending.each do |m|
      @cmd.query = nil      
      @cmd.scripts = [full_path(m)]
      @cmd.parameters = []
      puts "... Executing #{m}\r\n"
      @cmd.run      
      @cmd.parameters = []
      @cmd.scripts = []
      @cmd.query = "INSERT INTO #{MIGRATION_TABLE_NAME} (ID) VALUES (#{migration_number(m)})"
      puts @cmd.query 
      @cmd.run
    end
    
  end

  def full_path(file_name)
    migration_directory + "/" + file_name
  end

  def all_migrations
    Dir.entries(migration_directory).find_all {|f| f.match('.sql') }
  end

  def pending
    all_migrations.find_all {|m| migration_number(m) > self.last_run}
  end

  private
  
  def scalar(sql_result)
    sql_result.match('--\s+(\d+)').captures.first.to_i
  end

  def insure_migration_table_exists
    create_migration_table unless migration_table_exists?
  end

  def migration_table_exists?
    execute_sql "SELECT count(1) FROM sysobjects WHERE NAME = '#{MIGRATION_TABLE_NAME}'"    
    scalar(@cmd.result) > 0 
  end

  def create_migration_table
    execute_sql "CREATE TABLE #{MIGRATION_TABLE_NAME} (ID int NULL, CreateDate datetime NOT NULL DEFAULT(getdate())); INSERT INTO  #{MIGRATION_TABLE_NAME} (ID) VALUES(0)" 
  end

  def execute_sql(sql)    
    @cmd.query = sql
    @cmd.run
  end
  
  def migration_number(filename)
    match = filename.match '(\d+)_'
    match.captures.first.to_i
  end

end

