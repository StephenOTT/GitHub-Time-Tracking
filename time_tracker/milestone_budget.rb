require 'chronic_duration'
require_relative 'accepted_emoji'

module Gh_Milestone
	# include Accepted_Time_Tracking_Emoji

	def self.process_milestone(repo, milestoneDetail)
		# output = {}
		
		milestoneState = milestoneDetail.attrs[:state]
		milestoneTitle = milestoneDetail.attrs[:title]
		milestoneNumber = milestoneDetail.attrs[:number]
		
		milestoneCreatedAt = milestoneDetail.attrs[:created_at]
		milestoneClosedAt = milestoneDetail.attrs[:closed_at]
		milestoneDueDate = milestoneDetail.attrs[:due_on]

		milestoneDescription = milestoneDetail.attrs[:description]

		recordCreationDate = Time.now.utc
				

		budgetTime = []

		# cycles through each comment and returns time tracking 
		# checks to see if there is a time comment in the body field
		isBudgetComment = budget_comment?(milestoneDescription)
		if isBudgetComment == true
			# if true, the body field is parsed for time comment details
			parsedBudget = process_budget_description_for_time(milestoneDescription)
			if parsedBudget != nil
				# assuming results are returned from the parse (aka the parse was preceived 
				# by the code to be sucessful, the parsed time comment details array is put into
				# the commentsTime array)
				budgetTime << parsedBudget
			end
		end

		return output = {	"repo" => repo,
							"milestone_state" => milestoneState,
							"milestone_title" => milestoneTitle,
							"milestone_number" => milestoneNumber,
							"milestone_due_date" => milestoneDueDate,
							"milestone_created_at" => milestoneCreatedAt,
							"milestone_closed_at" => milestoneClosedAt,
							"record_creation_date" => recordCreationDate,
							"budget_tracking_commits" => budgetTime, }	
	end

		# Gets the milestone ID number assigned to the issue
	def self.get_issue_milestone_number(milestoneDetails)
		if milestoneDetails != nil
			return milestoneDetails.attrs[:number]
		end
	end

	# Is it a time comment?  Returns True or False
	def self.budget_comment?(commentBody)
		acceptedBudgetEmoji = Accepted_Time_Tracking_Emoji.accepted_milestone_budget_emoji

		acceptedBudgetEmoji.any? { |w| commentBody =~ /\A#{w}/ }
	end

	# does the comment contain the :free: emoji that indicates its non-billable
	def self.non_billable?(commentBody)
		acceptedNonBilliableEmoji = Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji
		return acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
	end

		# processes a budget description for time comment information
	def self.process_budget_description_for_time(budgetComment)

		type = "milestone budget"
		nonBillable = non_billable?(budgetComment)
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

		parsedCommentHash = { "duration" => nil, "non_billable" => nil}
		parsedComment = []
		acceptedBudgetEmoji.each do |x|
			if nonBillableTime == true
				acceptedNonBilliableEmoji.each do |b|
					if timeComment =~ /\A#{x}\s#{b}/
						parsedComment = parse_non_billable_time_comment(timeComment,x,b)
						parsedCommentHash["non_billable"] = true
						break
					end
				end
			elsif nonBillableTime == false
				if timeComment =~ /\A#{x}/
					parsedComment = parse_billable_time_comment(timeComment,x)
					parsedCommentHash["non_billable"] = false
					break
				end
			end
		end
		if parsedComment.empty? == true
			return nil
		end

		if parsedComment[0] != nil
			parsedCommentHash["duration"] = get_duration(parsedComment[0])
		end

		if parsedComment[1] != nil
			parsedCommentHash["time_comment"] = get_time_commit_comment(parsedComment[1])
		end

		return parsedCommentHash
	end

	def self.parse_non_billable_time_comment(timeComment, timeEmoji, nonBillableEmoji)
		return timeComment.gsub("#{timeEmoji} #{nonBillableEmoji} ","").split(" | ")
	end

	def self.parse_billable_time_comment(timeComment, timeEmoji)
		return timeComment.gsub("#{timeEmoji} ","").split(" | ")
	end

	# parses the durationText variable through ChronicDuration
	def self.get_duration(durationText)
		return ChronicDuration.parse(durationText)
	end

	def self.get_time_commit_comment(parsedTimeComment)
		return parsedTimeComment.lstrip.gsub("\r\n", " ")
	end

end