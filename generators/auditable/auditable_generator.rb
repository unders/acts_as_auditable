class AuditableGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.template 'model.rb', File.join('app', 'models', 'audit.rb')
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_audits"
    end
  end
end
