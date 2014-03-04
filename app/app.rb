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
      # authenticate!
      if authenticated? == true
        @username = github_user.login
        @gravatar_id = github_user.gravatar_id
        @fullName = github_user.name


      else
        # @dangerMessage = "Danger... Warning!  Warning"
        @warningMessage = "Please login to continue"
        # @infoMessage = "Info 123"
        # @successMessage = "Success"
      end
      erb :index
    end

    end

    get '/timetrack/:user/:repo' do
      authenticate!
      Sinatra_Helpers.download_time_tracking_data(params['user'], params['repo'], github_api)
      
      @downloadStatus = "Complete"

      erb :download_data
    end

    get '/analyze-issues/:user/:repo' do
      @issues = Sinatra_Helpers.analyze_issues(params['user'], params['repo'])

      erb :issues

    end

    get '/analyze-milestones/:user/:repo' do
      @milestones = Sinatra_Helpers.analyze_milestones(params['user'], params['repo'])

      erb :milestones

    end

    get '/analyze-issue-time/:user/:repo/:issueNumber' do
      @issueTime = Sinatra_Helpers.analyze_issueTime(params['user'], params['repo'], params['issueNumber'])

      erb :issue_time

    end


    get '/analyze-milestone-time/:user/:repo/:milestoneNumber' do
      @issuesInMilestone = Sinatra_Helpers.analyze_issue_time_in_milestone(params['user'], params['repo'], params['milestoneNumber'])

      erb :issues_in_milestone

    end

    # TODO: Write better code/route to support multiple categories and labels
    get '/analyze-labels-time/:user/:repo/:category/:label' do
      category = []
      label = []
      
      category << params['category']
      label << params['label']

      @labelsTime = Sinatra_Helpers.analyze_labelTime(params['user'], params['repo'], category, label)

      erb :labels

    end

    get '/analyze-code-commits/:user/:repo' do
      @codeCommits = Sinatra_Helpers.analyze_codeCommits(params['user'], params['repo'])

      erb :code_commits

    end




    get '/logout' do
      logout!
      redirect '/'
    end
    get '/login' do
      authenticate!
      redirect '/'
    end


  end
end
