require 'redmine'

#RAILS_DEFAULT_LOGGER.info 'Starting Redmine SLA plugin'

Redmine::Plugin.register :redmine_issue_sla do
  name 'Redmine Issue SLA'
  author 'Ricardo Santos & Sebastián Labonia'
  description 'Show SLA information for support tickets'
  version '2.0.0'
  requires_redmine :version_or_higher => '3.0.0'

  project_module :redmine_issue_sla do
    permission :view_issue_sla, {:issues => [:index, :show]}, :require => :member
    permission :manage_issue_sla, {:issue_slas => [:update]}, :require => :member
    permission :be_project_manager, {}, :require => :member
  end
end

RedmineApp::Application.config.after_initialize do
  require_dependency 'redmine_issue_sla/infectors'
end

# hooks
require_dependency 'redmine_issue_sla/hooks'
