require_relative 'users_aggregation'
require_relative 'helpers'


module Users_Processor

    def self.analyze_issues_users(user, repo, issueNumber)
      userRepo = "#{user}/#{repo}"
      Users_Aggregation.controller
      spentHours = Users_Aggregation.analyze_user_spent_hours_on_issue(issueNumber.to_i)
      # budgetHours = Users_Aggregation.analyze_issue_budget_hours
      # issues = Helpers.merge_issue_time_and_budget(spentHours, budgetHours)
      spentHours.each do |x|
        if x["time_duration_sum"] != nil
          x["time_duration_sum_human"] = Helpers.convertSecondsToDurationFormat(x["time_duration_sum"], "long")
        end
        # if x["budget_duration_sum"] != nil
        #   x["budget_duration_sum_human"] = Helpers.convertSecondsToDurationFormat(x["budget_duration_sum"], "long")
        # end
      end

      # issues = self.process_issues_for_budget_left(issues)

      return spentHours

    end



    def self.process_issues_for_budget_left(issues)
      issues.each do |i|
        if i["budget_duration_sum"] != nil
          # TODO Cleanup code for Budget left.
          budgetLeftRaw = Helpers.budget_left?(i["budget_duration_sum"], i["time_duration_sum"])
          budgetLeftHuman = Helpers.convertSecondsToDurationFormat(budgetLeftRaw, "long")
          i["budget_left_raw"] = budgetLeftRaw
          i["budget_left_human"] = budgetLeftHuman
        end
      end
      return issues
    end


end