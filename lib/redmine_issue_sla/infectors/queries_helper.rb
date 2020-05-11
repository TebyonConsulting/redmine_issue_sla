module RedmineIssueSla
  module Infectors
    module QueriesHelper
      module ClassMethods; end

      module InstanceMethods

        def column_value_with_issue_slas(column, item, value)
          case column.name 
          when :first_expiration_date
            if item.first_expiration_date.nil?
              return column_value_without_issue_slas(column, item, value)
            end

            now = Time.now
            if !item.first_response_date.nil?
              l(:expiration_status_replied)
            elsif value.future?
              # distance_of_time_in_words(now, value)
              l('datetime.distance_in_words.x_hours', :count => ((value - now)/1.hour).round(2))
            else
              l(:expiration_status_overdue)
            end
          when :close_expiration_date
            if item.close_expiration_date.nil?
              return column_value_without_issue_slas(column, item, value)
            end

            now = Time.now
            if item.closed_on.nil?
              if item.close_expiration_date.nil?
                return column_value_without_issue_slas(column, item, value)
              elsif value.future?
                l('datetime.distance_in_words.x_hours', :count => ((value - now)/1.hour).round(2))
              else
                l(:expiration_status_overdue)
              end
            else
              l(:expiration_status_replied)
            end
          when :id
            link_to value, issue_path(item)
          when :subject
            link_to value, issue_path(item)
          when :parent
            value ? (value.visible? ? link_to_issue(value, :subject => false) : "##{value.id}") : ''
          when :description
            item.description? ? content_tag('div', textilizable(item, :description), :class => "wiki") : ''
          when :last_notes
            item.last_notes.present? ? content_tag('div', textilizable(item, :last_notes), :class => "wiki") : ''
          when :done_ratio
            progress_bar(value)
          when :relations
            content_tag(
              'span',
              value.to_s(item) {|other| link_to_issue(other, :subject => false, :tracker => false)}.html_safe,
              :class => value.css_classes_for(item))
          when :hours, :estimated_hours, :total_estimated_hours
            format_hours(value)
          when :spent_hours
            link_to_if(value > 0, format_hours(value), project_time_entries_path(item.project, :issue_id => "#{item.id}"))
          when :total_spent_hours
            link_to_if(value > 0, format_hours(value), project_time_entries_path(item.project, :issue_id => "~#{item.id}"))
          when :attachments
            value.to_a.map {|a| format_object(a)}.join(" ").html_safe
          else
            format_object(value)
          end
        end

        def _expiration_in_words(issue)
          if issue.first_response_date.present?
            time = distance_of_time_in_words(issue.created_on, issue.first_response_date, :include_seconds => true)
            l(:expiration_status_replied_in_x_time, time)
          elsif issue.first_expiration_date.future?
            time = distance_of_time_in_words_to_now(issue.first_expiration_date, :include_seconds => true)
            l(:expiration_status_expires_in_x_time, time)
          else
            time = distance_of_time_in_words_to_now(issue.first_expiration_date, :include_seconds => true)
            l(:expiration_status_x_time_overdue, time)
          end

          if issue.closed_on.present?
            time = distance_of_time_in_words(issue.created_on, issue.closed_on, :include_seconds => true)
            l(:expiration_status_replied_in_x_time, time)
          elsif issue.close_expiration_date.future?
            time = distance_of_time_in_words_to_now(issue.close_expiration_date, :include_seconds => true)
            l(:expiration_status_expires_in_x_time, time)
          else
            time = distance_of_time_in_words_to_now(issue.close_expiration_date, :include_seconds => true)
            l(:expiration_status_x_time_overdue, time)
          end
        end

      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.class_eval do
          unloadable
          #alias_method_chain :column_value, :issue_sla
          alias_method :column_value_without_issue_slas, :column_value
          alias_method :column_value, :column_value_with_issue_slas          
          alias_method :expiration_in_words, :_expiration_in_words
        end
      end
    end
  end
end

#QueriesHelper.prepend RedmineIssueSla::Infectors::QueriesHelper
