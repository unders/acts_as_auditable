require 'digest/sha1'

module Shooter
  module Acts
    module Auditable
      def self.included(base)
        base.extend Shooter::Acts::Auditable::ClassMethods
      end

      module ClassMethods
        def audit(options = {})
          options.assert_valid_keys(:when, :if, :with_message)
          
          unless auditable?
            include Shooter::Acts::Auditable::InstanceMethods
            cattr_accessor :audit_items
            attr_accessor :auditor

            has_many :audits, :as => :auditable
            
            validate :ensure_auditor_is_assigned_if_audited, :if => lambda {|m| m.will_be_audited? }
          end
          
          self.audit_items ||= []

          options.merge!(:key => (key = generate_audit_key))
          
          self.audit_items << options
          
          self.class_eval <<-EOV
            #{options[:when]} do |audited_model|
              puts "starting callback now\n\n\n"
              puts audited_model.auditor.inspect
              item = audit_items.find {|item| item[:key] == "#{key}"}
              if (should_call = item[:if]).is_a?(Proc) ? should_call.call(audited_model) : audited_model.send(should_call)
                message = (msg = item[:with_message]).is_a?(Proc) ? msg.call(audited_model) : audited_model.send(msg)
                audited_model.audits.create(:message => message, :auditor => audited_model.auditor)
              end
            end
          EOV
        end
        
        def auditable?
          self.included_modules.include?(InstanceMethods)
        end
        
        private
        
        def generate_audit_key
          Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
        end
      end

      module InstanceMethods
        def will_be_audited?
          self.class.audit_items.map {|audit_item| audit_item[:if] }.any? {|item| item.is_a?(Proc) ? item.call(self) : self.send(item) }
        end
        
        protected
        
        def ensure_auditor_is_assigned_if_audited
          errors.add(:auditor, "needs to be assigned") unless self.auditor
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Shooter::Acts::Auditable