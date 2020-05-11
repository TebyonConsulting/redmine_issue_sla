# Sample plugin controller
class IssueSlasController < ApplicationController
  unloadable

  before_action :find_project_by_project_id
  before_action :authorize, :only => [:update]


#{}"issue_sla"=>{"1"=>{"first_delay"=>"1", "close_delay"=>"2"},
 #             "2"=>{"first_delay"=>"", "close_delay"=>""},
 #             "3"=>{"first_delay"=>"", "close_delay"=>""},
 #             "4"=>{"first_delay"=>"", "close_delay"=>""},
 #             "16"=>{"first_delay"=>"", "close_delay"=>""}
 #           }

  def update
    params[:issue_sla].each do |sla, data|
      new_issue_sla = @project.issue_slas.find_by_priority_id(sla)

      if data['first_delay'].present?
        new_issue_sla.first_delay = data['first_delay'].to_f
      else
        new_issue_sla.first_delay = nil
      end

      if data['close_delay'].present?
        new_issue_sla.close_delay = data['close_delay'].to_f
      else
        new_issue_sla.close_delay = nil
      end
      
      new_issue_sla.save
    end
    
    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path(@project, :tab => 'issue_sla')
  end

end
