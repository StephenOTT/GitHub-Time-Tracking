require_relative '../controller'
require_relative '../time_tracker/time_analyzer'

module Sinatra_Helpers

    def self.download_time_tracking_data(user,repo, githubObject)
      userRepo = "#{user}/#{repo}" 
      Time_Tracking_Controller.controller(userRepo, githubObject, true)
    end


    def self.analyze_issues(user,repo)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      spentHours = Time_Analyzer.analyze_issue_spent_hours
      budgetHours = Time_Analyzer.analyze_issue_budget_hours
      Time_Analyzer.merge_issue_time_and_budget(spentHours, budgetHours)
    end



end