require "web_console/view_helpers"
require "web_console/controller_helpers"

module WebConsole
  class Railtie < Rails::Railtie
    initializer "web_console.view_helpers" do
      ActiveSupport.on_load :action_view do
        include WebConsole::ViewHelpers
      end

      ActiveSupport.on_load :action_controller do
        prepend_view_path File.dirname(__FILE__) + '/../action_dispatch/templates'
        include WebConsole::ControllerHelpers
      end
    end
  end
end
