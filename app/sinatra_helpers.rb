require_relative '../controller'
require_relative '../time_analyzer/time_analyzer'
require_relative '../time_tracker/helpers'
require_relative '../time_analyzer/milestones_processor'
require_relative '../time_analyzer/issues_processor'
require_relative '../time_analyzer/users_processor'
require_relative '../time_analyzer/system_wide_processor'

module Sinatra_Helpers

    def self.get_all_repos_for_logged_user(githubAuthInfo)

      System_Wide_Processor.all_repos_for_logged_user(githubAuthInfo)

    end
    

      userRepo = "#{user}/#{repo}" 
      Time_Tracking_Controller.controller(userRepo, githubObject, true)
    end


    def self.issues(user, repo)

      Issues_Processor.analyze_issues(user, repo)

    end


    def self.milestones(user, repo)

      Milestones_Processor.milestones_and_issue_sums(user, repo)

    end

    def self.issues_users(user, repo, issueNumber)

      Users_Processor.analyze_issues_users(user, repo, issueNumber)

    end


    def self.analyze_issueTime(user, repo, issueNumber)
      userRepo = "#{user}/#{repo}"
      Issues_Processor.controller
      issuesTime = Issues_Processor.analyze_issue_spent_hours_per_user(userRepo, issueNumber.to_i)
      issuesTime.each do |x|
        if x["time_duration_sum"] != nil
          x["time_duration_sum"] = Helpers.convertSecondsToDurationFormat(x["time_duration_sum"], "long")
        end
        # if x["budget_duration_sum"] != nil
        #   x["budget_duration_sum"] = Helpers.chronic_convert(x["budget_duration_sum"], "long")
        # end
      end
    end

    def self.analyze_labelTime(user, repo, category, label)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      Time_Analyzer.analyze_issue_spent_hours_per_label(category, label)
    end

    def self.analyze_codeCommits(user, repo)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      Time_Analyzer.analyze_code_commits_spent_hours
    end

    # TODO come up with better way to call chronic duration
    def self.analyze_issue_time_in_milestone(user, repo, milestoneNumber)
      userRepo = "#{user}/#{repo}"
      puts milestoneNumber
      Time_Analyzer.controller
      issuesPerMilestone = Time_Analyzer.analyze_issue_spent_hours_per_milestone(milestoneNumber.to_i)
      issuesPerMilestone.each do |x|
        x["time_duration_sum"] = Helpers.convertSecondsToDurationFormat(x["time_duration_sum"], "long")
      end
      return issuesPerMilestone
    end


end