require_relative 'labels_processor'
require_relative 'helpers'
require_relative 'issue_budget'
require_relative 'issue_time'

module Gh_Issue

	def self.process_issue(repo, issueDetails, issueComments)
		
		issueState = issueDetails.attrs[:state]
		issueTitle = issueDetails.attrs[:title]
		issueNumber = issueDetails.attrs[:number]
		issueCreatedAt = issueDetails.attrs[:created_at]
		issueClosedAt = issueDetails.attrs[:closed_at]
		issueLastUpdatedAt = issueDetails.attrs[:updated_at]
		recordCreationDate = Time.now.utc
		
		# gets the milestone number assigned to a issue.  Is not milestone assigned then returns nil
		milestoneNumber = Helpers.get_issue_milestone_number(issueDetails.attrs[:milestone])
		
		# gets labels data for issue and returns array of label strings
		labelNames = Labels_Processor.get_label_names(issueDetails.attrs[:labels])
		
		# runs the label names through a parser to create Label categories.  
		# used for advanced label grouping
		labels = Labels_Processor.process_issue_labels(labelNames)

		commentsTime = []

		# cycles through each comment and returns time tracking 
		issueComments.each do |x|
			# checks to see if there is a time comment in the body field
			isTimeComment = Helpers.time_comment?(x.attrs[:body])
			isBudgetComment = Helpers.budget_comment?(x.attrs[:body])
			if isTimeComment == true
				# if true, the body field is parsed for time comment details
				parsedTime = Gh_Issue_Time.process_issue_comment_for_time(x)
				if parsedTime != nil
					# assuming results are returned from the parse (aka the parse was preceived 
					# by the code to be sucessful, the parsed time comment details array is put into
					# the commentsTime array)
					commentsTime << parsedTime
				end
			end
			
			if isBudgetComment == true
				parsedBudget = Gh_Issue_Budget.process_issue_comment_for_budget(x)
				if parsedBudget != nil
					commentsTime << parsedBudget
				end
			end

			parsedTasks = Gh_Issue_Comment_Tasks.process_issue_comment_for_task_time(x)
			if parsedTasks["tasks"].empty? == false
				commentsTime << parsedTasks
			end
			
		end

		return output = {	"repo" => repo,
							"issue_state" => issueState,
							"issue_title" => issueTitle,
							"issue_number" => issueNumber,
							"milestone_number" => milestoneNumber,
							"labels" => labels,
							"issue_created_at" => issueCreatedAt,
							"issue_closed_at" => issueClosedAt,
							"issue_last_updated_at" => issueLastUpdatedAt,
							"record_creation_date" => recordCreationDate,
							"time_tracking_commits" => commentsTime, }	
	end
end