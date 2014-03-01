require_relative '../controller'
require_relative '../time_tracker/time_analyzer'
require_relative '../time_tracker/helpers'

module Sinatra_Helpers

    def self.download_time_tracking_data(user, repo, githubObject)
      userRepo = "#{user}/#{repo}" 
      Time_Tracking_Controller.controller(userRepo, githubObject, true)
    end


    def self.analyze_issues(user, repo)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      spentHours = Time_Analyzer.analyze_issue_spent_hours
      budgetHours = Time_Analyzer.analyze_issue_budget_hours
      Time_Analyzer.merge_issue_time_and_budget(spentHours, budgetHours)
    end

    def self.analyze_milestones(user, repo)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      Time_Analyzer.analyze_milestones
    end

    def self.analyze_issueTime(user, repo, issueNumber)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      Time_Analyzer.analyze_issue_spent_hours_per_user(userRepo, issueNumber.to_i)
    end

    # TODO Cleanup dog code.
    # TODO come up with better way to call chronic duration
    def self.analyze_issue_time_in_milestone(user, repo, milestoneNumber)
      userRepo = "#{user}/#{repo}"
      puts milestoneNumber
      Time_Analyzer.controller
      dog = Time_Analyzer.analyze_issue_spent_hours_per_milestone(milestoneNumber.to_i)
      dog.each do |x|
        x["time_duration_sum"] = Helpers.chronic_convert(x["time_duration_sum"], "long")
      end
      return dog
    end
end