require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class ScraperLineups < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-check'
        end
      end
    end
  end
end
