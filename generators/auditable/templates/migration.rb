class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.belongs_to :auditable
      t.string :auditable_type
      
      t.string :message
      t.belongs_to :auditor
      t.string :auditor_name
      t.timestamps
    end
    
    [[:auditable_type, :auditable_id], :auditor_id, :auditor_name, :created_at].each do |column|
      add_index :audits, column
    end
  end

  def self.down
    drop_table :audits
  end
end