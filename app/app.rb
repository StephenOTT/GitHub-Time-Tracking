require_relative 'sinatra_helpers'

module Example
  class App < Sinatra::Base
    enable :sessions

    set :github_options, {
      :scopes    => "user",
      :secret    => ENV['GITHUB_CLIENT_SECRET'],
      :client_id => ENV['GITHUB_CLIENT_ID'],
    }

    register Sinatra::Auth::Github

    helpers do

      def get_auth_info
        authInfo = {:username => github_user.login, :userID => github_user.id}
      end

    end

    get '/' do
      # authenticate!
      if authenticated? == true
        @username = github_user.login
        @gravatar_id = github_user.gravatar_id
        @fullName = github_user.name
        @userID = github_user.id


      else
        # @dangerMessage = "Danger... Warning!  Warning"
        @warningMessage = "Please login to continue"
        # @infoMessage = "Info 123"
        # @successMessage = "Success"
      end
      erb :index
    end

    get '/repos' do
      if authenticated? == true
        @reposList = Sinatra_Helpers.get_all_repos_for_logged_user(get_auth_info)
        erb :repos_listing
      else
        @warningMessage = "You must be logged in"
        erb :unauthenticated
      end     
    end




    get '/timetrack' do
      if authenticated? == true
        erb :download_data
      else
        @warningMessage = "You must be logged in"
        erb :unauthenticated
      end     
    end

    get '/download/:user/:repo' do
      authenticate!
      Sinatra_Helpers.download_time_tracking_data(params['user'], params['repo'], github_api, get_auth_info )
      @successMessage = "Download Complete"
      redirect '/timetrack'
    end

    # get '/analyze-issues/:user/:repo' do
    #   issuesRaw = Sinatra_Helpers.analyze_issues(params['user'], params['repo'])
    #   issuesProcessed = Sinatra_Helpers.process_issues_for_budget_left(issuesRaw)
     

    #   @issues = issuesProcessed
    #   erb :issues

    # end

    get '/:user/:repo/issues' do
      if authenticated? == true
        @issues = Sinatra_Helpers.issues(params['user'], params['repo'], get_auth_info)
        erb :issues
      else
        @warningMessage = "You must be logged in"
        erb :unauthenticated
      end  

    end

    get '/:user/:repo/milestones' do
      # milestones1 = Sinatra_Helpers.analyze_milestones(params['user'], params['repo'])
      # milestonesProcessed = Sinatra_Helpers.process_milestone_budget_left(milestones1)
      if authenticated? == true
      @milestones = Sinatra_Helpers.milestones(params['user'], params['repo'], get_auth_info)
      erb :milestones
      else
        @warningMessage = "You must be logged in"
        erb :unauthenticated
      end   
    end

    get '/:user/:repo/milestone/:milestoneNumber/issues' do
      @issuesInMilestone = Sinatra_Helpers.milestone_issues(params['user'], params['repo'], params['milestoneNumber'], get_auth_info)
      erb :issues_in_milestone
    end

    # Old route: get '/issues-spent-hours/:user/:repo/:issueNumber' do
    get '/:user/:repo/issues/:issueNumber' do
      @issues_spent_hours = Sinatra_Helpers.issues_users(params['user'], params['repo'], params['issueNumber'], get_auth_info)
      erb :issue_time

    end




    # get '/analyze-issue-time/:user/:repo/:issueNumber' do
    #   @issueTime = Sinatra_Helpers.analyze_issueTime(params['user'], params['repo'], params['issueNumber'])

    #   erb :issue_time

    # end



    # get '/analyze-milestone-time/:user/:repo/:milestoneNumber' do
    #   @issuesInMilestone = Sinatra_Helpers.analyze_issue_time_in_milestone(params['user'], params['repo'], params['milestoneNumber'])

    #   erb :issues_in_milestone

    # end

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