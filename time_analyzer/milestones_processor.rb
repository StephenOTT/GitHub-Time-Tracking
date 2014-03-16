require_relative 'milestones_aggregation'
require_relative 'issues_aggregation'
require_relative 'helpers'


module Milestones_Processor

	def self.milestones_and_issue_sums(user, repo, githubAuthInfo)
		userRepo = "#{user}/#{repo}"
		
		Milestones_Aggregation.controller # makes mongo connection
		
		milestones = Milestones_Aggregation.get_all_milestones_budget(userRepo, githubAuthInfo)
		
		milestones.each do |x|
		x["milestone_duration_sum_human"] = Helpers.convertSecondsToDurationFormat(x["milestone_duration_sum"], "long")

		# get the total hours of time spent on issues assigned to the milestone(x)
		issuesSpentHours = Issues_Aggregation.get_total_issues_time_for_milestone(userRepo, [x["milestone_number"]])
		
		if issuesSpentHours.empty? == false # array would be empty if there was no time allocated to the issues in the milestone
			issuesSpentHoursHuman = Helpers.convertSecondsToDurationFormat(issuesSpentHours[0]["time_duration_sum"], "long")
			x["issues_duration_sum"] = issuesSpentHours[0]["time_duration_sum"]
			x["issues_duration_sum_human"] = issuesSpentHoursHuman
		else
			issuesSpentHoursHuman = Helpers.convertSecondsToDurationFormat(0, "long")
			x["issues_duration_sum"] = 0
			x["issues_duration_sum_human"] = issuesSpentHoursHuman
		end

		budgetLeftRaw = Helpers.budget_left?(x["milestone_duration_sum"], x["issues_duration_sum"])
		budgetLeftHuman = Helpers.convertSecondsToDurationFormat(budgetLeftRaw, "long")
		x["budget_left"] = budgetLeftRaw
		x["budget_left_human"] = budgetLeftHuman

		end
		return milestones
	end
end