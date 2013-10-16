require 'sinatra/base'
require 'web_console/console_session'

module WebConsole
  class RackApp < Sinatra::Base
    before do
      unless request.ip.in?(WebConsole.config.whitelisted_ips)
        halt 403
      end
    end

    set :root, File.expand_path(File.dirname(__FILE__) + "/../../rack_app")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views, Proc.new { "#{root}/views" }
    set :locales, Proc.new { "#{root}/locales" }

    set :static, true

    set :show_exceptions, false

    error ConsoleSession::Unavailable do
      status 410 # :gone
      request.env['sinatra.error'].to_json
    end

    error ConsoleSession::Invalid do
      status 422 #:unprocessable_entity
      request.env['sinatra.error'].to_json
    end

    get '/' do
      @console_session = ConsoleSession.create

      erb :index
    end

    get '/console_sessions.css' do
      content_type 'text/css'

      @style = WebConsole.config.style

      erb :console_style
    end

    put '/input/:pid' do
      pid = params[:pid]

      @console_session = ConsoleSession.find(pid)
      @console_session.send_input(params[:input])

      200
    end

    get '/pending_output/:pid' do
      pid = params[:pid]

      @console_session = ConsoleSession.find(pid)

      { output: @console_session.pending_output }.to_json
    end

    put '/configuration/:pid' do
      pid = params[:pid]

      @console_session = ConsoleSession.find(pid)

      console_params = params.slice(:input, :width, :height)
      @console_session.configure(console_params)

      200
    end

    helpers do
      def root_path
        "#{env['SCRIPT_NAME']}/"
      end
    end
  end
end
