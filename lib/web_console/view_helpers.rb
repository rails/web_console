module WebConsole
  module ViewHelpers
    def console(console_binding = nil)
      if WebConsole.binding_of_caller_available?
        console_binding ||= binding.of_caller(1)
      end

      if controller.should_render_console
        @console_session = WebConsole::REPLSession.create(
          binding: console_binding
        )

        controller.should_render_console = false
        render('rescues/web_console')
      end
    end
  end
end
