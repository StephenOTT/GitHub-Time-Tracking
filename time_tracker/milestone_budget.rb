require_relative 'accepted_emoji'
require_relative 'helpers'

module Gh_Milestone_Budget

		# processes a budget description for time comment information
	def self.process_budget_description_for_time(budgetComment)

		type = "Milestone Budget"
		nonBillable = Helpers.non_billable?(budgetComment)
		parsedTimeDetails = parse_time_commit(budgetComment, nonBillable)
		if parsedTimeDetails == nil
			return nil
		else
			overviewDetails = {"type" => type,
								"record_creation_date" => Time.now.utc}
			mergedHash = parsedTimeDetails.merge(overviewDetails)
			return mergedHash
		end
	end

	def self.parse_time_commit(timeComment, nonBillableTime)
		acceptedBudgetEmoji = Accepted_Time_Tracking_Emoji.accepted_milestone_budget_emoji
		acceptedNonBilliableEmoji = Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji

		parsedCommentHash = { "duration" => nil, "non_billable" => nil, "time_comment" => nil}
		parsedComment = []
		acceptedBudgetEmoji.each do |x|
			if nonBillableTime == true
				acceptedNonBilliableEmoji.each do |b|
					if timeComment =~ /\A#{x}\s#{b}/
						parsedComment = Helpers.parse_non_billable_time_comment(timeComment,x,b)
						parsedCommentHash["non_billable"] = true
						break
					end
				end
			elsif nonBillableTime == false
				if timeComment =~ /\A#{x}/
					parsedComment = Helpers.parse_billable_time_comment(timeComment,x)
					parsedCommentHash["non_billable"] = false
					break
				end
			end
		end
		if parsedComment.empty? == true
			return nil
		end

		if parsedComment[0] != nil
			parsedCommentHash["duration"] = Helpers.get_duration(parsedComment[0])
		end

		if parsedComment[1] != nil
			parsedCommentHash["budget_comment"] = Helpers.get_time_commit_comment(parsedComment[1])
		end

		return parsedCommentHash
	end

end