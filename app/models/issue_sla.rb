class IssueSla < ActiveRecord::Base
  belongs_to :project, :class_name => 'Project', :foreign_key => 'project_id'
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'

  validates_presence_of :priority, :project
  validates_numericality_of :first_delay, :allow_nil => true
  validates_numericality_of :close_delay, :allow_nil => true

  #attr_protected :priority_id, :project_id

  before_save :update_issues

  private
  def update_issues
    project.issues.open.where(:priority_id => priority.id).all.each do |issue|
      next if issue.closed_on.present?

      if close_delay.present?
        date = close_delay.hours.since(issue.created_on).round
      end
      #if issue.close_expiration_date != date
      #  issue.init_journal(User.current)
      #  issue.current_journal.attributes_before_change['close_expiration_date'] = date
      #  issue.update_attributes(:close_expiration_date => date, :issue_sla => close_delay)
      #end

      next if issue.first_response_date.present?

      date = nil
      if first_delay.present?
        date = first_delay.hours.since(issue.created_on).round
      end
      #if issue.first_expiration_date != date
      #  issue.init_journal(User.current)
      #  issue.current_journal.attributes_before_change['first_expiration_date'] = date
      #  issue.update_attributes(:first_expiration_date => date, :issue_sla => first_delay)
      #end
    end
  end
end
