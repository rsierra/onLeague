require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class ScrapGoals < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :visible? do
          false
        end

        register_instance_option :controller do
          Proc.new do
            @object.scrap_goals params[:scrap_url]
            render :edit
          end
        end
      end
    end
  end
end
