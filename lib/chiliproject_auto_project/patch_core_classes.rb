require_dependency "project"

module Plugin
  module AutoProject
    module User
      module ClassMethods
      end
      
      module InstanceMethods
        def remember_if_activated
          @was_activated = false
          return unless ((self.status_change == [::User::STATUS_REGISTERED, ::User::STATUS_ACTIVE]) ||
                         (self.new_record? && self.status == ::User::STATUS_ACTIVE))
          user_project_identifier = login.gsub /[@.]/, '_'
          return if Project.find_by_identifier user_project_identifier
          @was_activated = true
        end
        
        def build_user_project
          return unless @was_activated
          user_project_identifier = login.gsub /[@.]/, '_'
          user_project = Project.create :identifier => user_project_identifier, :name => name, :is_public => false
          user_project_role = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
          memberships.create :project => user_project, :roles => [user_project_role]
        end
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          before_save :remember_if_activated
          after_save :build_user_project
        end
      end
    end
  end
end

User.send(:include, Plugin::AutoProject::User)