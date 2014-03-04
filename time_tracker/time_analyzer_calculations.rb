# require_relative './mongo'

module Time_Analyzer_Calculations


	def self.budget_left?(budgetDurationSum, issueDurationSum)
		budgetDurationSum - issueDurationSum
	end
	
end


# DEBUG CODE for testing output of methods without the need of Sinatra.

# Time_Analyzer.controller

# puts Time_Analyzer.analyze_issue_spent_hours_per_user
# puts Time_Analyzer.analyze_issue_spent_hours_per_milestone(1)
# puts Time_Analyzer.analyze_issue_spent_hours_per_label(["Priority"], ["High", "Medium"])
# puts Time_Analyzer.analyze_code_commits_spent_hours

