require 'albacore/support/albacore_helper'

class Migrate

  def initialize(cmd)
    @cmd = cmd
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
    pending.each {|m| @cmd.scripts << full_path(m)} 
    @cmd.run 
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

  def scalar
    sql_result.match('--\s+(\d+)').captures.first    
  end

  def migration_number(filename)
    match = filename.match '(\d+)_'
    match.captures.first.to_i
  end

end
