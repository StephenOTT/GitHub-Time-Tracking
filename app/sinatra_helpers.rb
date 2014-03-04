require_relative '../controller'
require_relative '../time_tracker/time_analyzer'
require_relative '../time_tracker/helpers'
require_relative '../time_tracker/time_analyzer_calculations'


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
      issues = Time_Analyzer.merge_issue_time_and_budget(spentHours, budgetHours)
      issues.each do |x|
        if x["time_duration_sum"] != nil
          x["time_duration_sum_human"] = Helpers.chronic_convert(x["time_duration_sum"], "long")
        end
        if x["budget_duration_sum"] != nil
          x["budget_duration_sum_human"] = Helpers.chronic_convert(x["budget_duration_sum"], "long")
        end
      end
      return issues

    end

    def self.analyze_milestones(user, repo)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      milestones = Time_Analyzer.analyze_milestones
      milestones.each do |x|
        if x["milestone_duration_sum"] != nil
          x["milestone_duration_sum_human"] = Helpers.chronic_convert(x["milestone_duration_sum"], "long")
        end
        issuesSpentHours = Time_Analyzer.analyze_issue_spent_hours_for_milestone([x["milestone_number"]])
       if issuesSpentHours.empty? == false
          issuesSpentHoursHuman = Helpers.chronic_convert(issuesSpentHours[0]["time_duration_sum"], "long")
          x["issues_duration_sum_raw"] = issuesSpentHours[0]["time_duration_sum"]
          x["issues_duration_sum_human"] = issuesSpentHoursHuman
        else
          issuesSpentHoursHuman = Helpers.chronic_convert(0, "long")
          x["issues_duration_sum_raw"] = 0
          x["issues_duration_sum_human"] = issuesSpentHoursHuman

        end

      end
      return milestones
    end

    def self.analyze_issueTime(user, repo, issueNumber)
      userRepo = "#{user}/#{repo}"
      Time_Analyzer.controller
      issuesTime = Time_Analyzer.analyze_issue_spent_hours_per_user(userRepo, issueNumber.to_i)
      issuesTime.each do |x|
        if x["time_duration_sum"] != nil
          x["time_duration_sum"] = Helpers.chronic_convert(x["time_duration_sum"], "long")
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


    def self.process_issues_for_budget_left(issues)
      issues.each do |i|
        if i["budget_duration_sum"] != nil
          budgetLeftRaw = Time_Analyzer_Calculations.budget_left?(i["budget_duration_sum"], i["time_duration_sum"])
          budgetLeftHuman = Helpers.chronic_convert(budgetLeftRaw, "long")
          i["budget_left_raw"] = budgetLeftRaw
          i["budget_left_human"] = budgetLeftHuman
        end
      end
      return issues
    end


end