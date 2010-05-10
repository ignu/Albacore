create_task :sqlmigrate, Migrator.new do |cmd|
  cmd.migrate
end
