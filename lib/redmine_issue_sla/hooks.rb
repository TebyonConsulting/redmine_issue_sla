module RedmineIssueSla
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_new_before_save(context)
      save_expiration_date(context[:issue])
    end

    def controller_issues_edit_before_save(context)
      save_expiration_date(context[:issue])
    end

    def controller_issues_edit_before_save(context)
      save_expiration_date(context[:issue])
    end

    def controller_issues_bulk_edit_before_save(context)
      save_expiration_date(context[:issue])
    end

    def helper_issues_show_detail_after_setting(context)
      detail = context[:detail]

      case detail.prop_key
      when 'issue_sla'
        value = detail.value; old_value = detail.old_value

        if value
          detail.value = l('datetime.distance_in_words.x_hours', :count => value)
        end
        if old_value
          detail.old_value = l('datetime.distance_in_words.x_hours', :count => old_value)
        end
      end

      context[:detail] = detail
    end

    private
      def save_expiration_date(issue, user = User.current)
        return if issue.closed_on

        if issue.try(:current_journal).try(:attributes_before_change)
          previous_values = issue.current_journal.attributes_before_change
        else
          previous_values = {}
        end

        if user.allowed_to?(:add_issues, issue.project) && (issue.new_record? || issue.priority_id != previous_values['priority_id'])
            sla = issue.priority_issue_sla
            if sla && sla.close_delay.present?
              attrs = { :close_expiration_date => sla.close_delay.hours.from_now.round, :issue_sla => sla.close_delay }
              issue.assign_attributes attrs #, :without_protection => true
              previous_values['close_expiration_date'] = issue.close_expiration_date if previous_values
            end
        end

        #Close SLA
        #if user.allowed_to?(:be_project_manager, issue.project) && (issue.new_record? || issue.assigned_to_id != previous_values['assigned_to_id'])
        #  attrs = { :first_response_date => Time.now.round }
        #  issue.assign_attributes attrs #, :without_protection => true
        #  previous_values['first_response_date'] = issue.first_response_date if previous_values
        #end

        return if issue.first_response_date

        if issue.try(:current_journal).try(:attributes_before_change)
          previous_values = issue.current_journal.attributes_before_change
        else
          previous_values = {}
        end

        if user.allowed_to?(:add_issues, issue.project) && (issue.new_record? || issue.priority_id != previous_values['priority_id'])
            sla = issue.priority_issue_sla
            if sla && sla.first_delay.present?
              attrs = { :first_expiration_date => sla.first_delay.hours.from_now.round, :issue_sla => sla.first_delay }
              issue.assign_attributes attrs #, :without_protection => true
              previous_values['first_expiration_date'] = issue.first_expiration_date if previous_values
            end
        end

        if user.allowed_to?(:be_project_manager, issue.project) && (issue.new_record? || issue.assigned_to_id != previous_values['assigned_to_id'])
          attrs = { :first_response_date => Time.now.round }
          issue.assign_attributes attrs #, :without_protection => true
          previous_values['first_response_date'] = issue.first_response_date if previous_values
        end
      end

  end

  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_details_bottom, :partial => "issues/show_first_expiration"
    render_on :view_issues_show_details_bottom, :partial => "issues/show_close_expiration"
  end
end
