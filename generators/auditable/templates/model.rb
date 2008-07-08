class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :auditor, :class_name => "User", :foreign_key => :auditor_id
  
  before_save do |model|
    model.auditor_name = model.auditor.auditor_name
  end
end