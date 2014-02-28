require_relative 'sinatra_helpers'

module Example
  class App < Sinatra::Base
    enable :sessions

    set :github_options, {
      :scopes    => "user",
      :secret    => ENV['GITHUB_CLIENT_SECRET'],
      :client_id => ENV['GITHUB_CLIENT_ID'],
      # :scope     => 'read:org'
    }

    register Sinatra::Auth::Github

    helpers do
      def repos
        github_request("user/repos")
      end
    end

    get '/' do
      authenticate!
      "Hello there, #{github_user.login}!"
    end

    get '/orgs/:id' do
      github_organization_authenticate!(params['id'])
      "Hello There, #{github_user.name}! You have access to the #{params['id']} organization."
    end

    get '/publicized_orgs/:id' do
      github_publicized_organization_authenticate!(params['id'])
      "Hello There, #{github_user.name}! You are publicly a member of the #{params['id']} organization."
    end

    get '/teams/:id' do
      github_team_authenticate!(params['id'])
      "Hello There, #{github_user.name}! You have access to the #{params['id']} team."
    end

    get '/timetrack/:user/:repo' do
      authenticate!
      Sinatra_Helpers.download_time_tracking_data(params['user'],params['repo'],github_api)
      "Download Complete"
    end

    get '/analyze-issues/:user/:repo' do
      @issues = Sinatra_Helpers.analyze_issues(params['user'],params['repo'])

      erb :issues

    end

    get '/analyze-milestones/:user/:repo' do
      @milestones = Sinatra_Helpers.analyze_milestones(params['user'],params['repo'])

      erb :milestones

    end

    get '/logout' do
      logout!
      redirect 'https://github.com'
    end
  end
end
