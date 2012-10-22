require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class CloseWeek < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-check'
        end

        register_instance_option :controller do
          Proc.new do
            if @object.close_week
              @object.notify_team_points
              @object.notify_inactive_teams
              flash[:notice] = I18n.t('admin.actions.close_week.done')
            else
              flash[:error] = I18n.t('admin.actions.close_week.error')
            end
            redirect_to back_or_index
          end
        end
      end
    end
  end
end
