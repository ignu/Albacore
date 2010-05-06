require 'albacore/support/albacore_helper'

class Migrate

  def migration_directory
    File.join(File.dirname(__FILE__), "migrations")
    'c:/code/oss/Albacore/spec/support/migrations'
  end

  def last_run
    0
  end

  def all_migrations
    Dir.entries(migration_directory).find_all {|f| f.match('.sql') }
  end

  def pending
    all_migrations.find_all {|m| migration_number(m) > self.last_run}
  end

  private

  def migration_number(filename)
    match = filename.match '(\d+)_'
    match.captures.first.to_i
  end
end
