require_relative 'helpers'
require_relative 'milestone_budget'

module Gh_Milestone

	def self.process_milestone(repo, milestoneDetail)
		
		milestoneState = milestoneDetail.attrs[:state]
		milestoneTitle = milestoneDetail.attrs[:title]
		milestoneNumber = milestoneDetail.attrs[:number]
		
		milestoneCreatedAt = milestoneDetail.attrs[:created_at]
		milestoneClosedAt = milestoneDetail.attrs[:closed_at]
		milestoneDueDate = milestoneDetail.attrs[:due_on]
		milestoneOpenIssueCount = milestoneDetail.attrs[:open_issues]
		milestoneClosedIssueCount = milestoneDetail.attrs[:closed_issues]

		milestoneDescription = milestoneDetail.attrs[:description]

		recordCreationDate = Time.now.utc
				

		budgetTime = []

		# cycles through each comment and returns time tracking 
		# checks to see if there is a time comment in the body field
		isBudgetComment = Helpers.budget_comment?(milestoneDescription)
		if isBudgetComment == true
			# if true, the body field is parsed for time comment details
			parsedBudget = Gh_Milestone_Budget.process_budget_description_for_time(milestoneDescription)
			if parsedBudget != nil
				# assuming results are returned from the parse (aka the parse was preceived 
				# by the code to be sucessful, the parsed time comment details array is put into
				# the commentsTime array)
				budgetTime << parsedBudget
			end
		end

		if budgetTime.empty? == false
			return output = {	"repo" => repo,
								"type" => "Milestone",
								"milestone_state" => milestoneState,
								"milestone_title" => milestoneTitle,
								"milestone_number" => milestoneNumber,
								"milestone_due_date" => milestoneDueDate,
								"milestone_created_at" => milestoneCreatedAt,
								"milestone_closed_at" => milestoneClosedAt,
								"milestone_open_issue_count" => milestoneOpenIssueCount,
								"milestone_closed_issue_count" => milestoneClosedIssueCount,
								"record_creation_date" => recordCreationDate,
								"budget_tracking_commits" => budgetTime, }	
		elsif commentsTime.empty? == true
			return output = {}
		end
	end
end