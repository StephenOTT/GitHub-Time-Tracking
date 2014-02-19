require 'chronic_duration'
require_relative 'accepted_emoji'
require_relative 'labels_processor'

module Gh_Issue
	# include Accepted_Time_Tracking_Emoji

	def self.process_issue(repo, issueDetails, issueComments)
		# output = {}
		
		issueState = issueDetails.attrs[:state]
		issueTitle = issueDetails.attrs[:title]
		issueNumber = issueDetails.attrs[:number]
		issueCreatedAt = issueDetails.attrs[:created_at]
		issueClosedAt = issueDetails.attrs[:closed_at]
		issueLastUpdatedAt = issueDetails.attrs[:updated_at]
		recordCreationDate = Time.now.utc
		
		# gets the milestone number assigned to a issue.  Is not milestone assigned then returns nil
		milestoneNumber = get_issue_milestone_number(issueDetails.attrs[:milestone])
		
		# gets labels data for issue and returns array of label strings
		# labelNames = get_label_names(issueDetails.attrs[:labels])
		labelNames = Labels_Processor.get_label_names(issueDetails.attrs[:labels])
		
		# runs the label names through a parser to create Label categories.  
		# used for advanced label grouping
		# labels = process_issue_labels(labelNames)
		labels = Labels_Processor.process_issue_labels(labelNames)
		# gets the comments of the specific issue being processed---ADDED INTO METHOD PARAMETERS
		# issueComments = get_Issue_Comments(repo, issueDetails.attrs[:number])

		commentsTime = []

		# cycles through each comment and returns time tracking 
		issueComments.each do |x|
			# checks to see if there is a time comment in the body field
			isTimeComment = time_comment?(x.attrs[:body])
			if isTimeComment == true
				# if true, the body field is parsed for time comment details
				parsedTime = process_issue_comment_for_time(x)
				if parsedTime != nil
					# assuming results are returned from the parse (aka the parse was preceived 
					# by the code to be sucessful, the parsed time comment details array is put into
					# the commentsTime array)
					commentsTime << parsedTime
				end
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

		# Gets the milestone ID number assigned to the issue
	def self.get_issue_milestone_number(milestoneDetails)
		if milestoneDetails != nil
			return milestoneDetails.attrs[:number]
		end
	end

	# Is it a time comment?  Returns True or False
	def self.time_comment?(commentBody)
		acceptedClockEmoji = Accepted_Time_Tracking_Emoji.accepted_time_comment_emoji

		# acceptedClockEmoji.any? { |w| commentBody.attrs[:body] =~ /\A#{w}/ }
		acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ }
	end

	# does the comment contain the :free: emoji that indicates its non-billable
	def self.non_billable?(commentBody)
		acceptedNonBilliableEmoji = Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji
		return acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
	end

		# processes a comment for time comment information
	def self.process_issue_comment_for_time(issueComment)

		type = "Issue Time"
		issueCommentBody = issueComment.attrs[:body]
		nonBillable = non_billable?(issueCommentBody)
		parsedTimeDetails = parse_time_commit(issueCommentBody, nonBillable)
		if parsedTimeDetails == nil
			return nil
		else
			overviewDetails = {"type" => type,
								"comment_id" => issueComment.attrs[:id],
								"work_logged_by" => issueComment.attrs[:user].attrs[:login],
								"comment_created_date" => issueComment.attrs[:created_at],
								"comment_last_updated_date" =>issueComment.attrs[:updated_at],
								"record_creation_date" => Time.now.utc}
			mergedHash = parsedTimeDetails.merge(overviewDetails)
			return mergedHash
		end
	end

	def self.parse_time_commit(timeComment, nonBillableTime)
		acceptedClockEmoji = Accepted_Time_Tracking_Emoji.accepted_time_comment_emoji
		acceptedNonBilliableEmoji = Accepted_Time_Tracking_Emoji.accepted_nonBillable_emoji

		parsedCommentHash = { "duration" => nil, "non_billable" => nil, "work_date" => nil, "time_comment" => nil}
		parsedComment = []
		acceptedClockEmoji.each do |x|
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
			workDate = get_time_work_date(parsedComment[1])
				if workDate != nil
					parsedCommentHash["work_date"] = workDate
				elsif workDate == nil
					parsedCommentHash["time_comment"] = get_time_commit_comment(parsedComment[1])
				end
		end
		if parsedComment[2] != nil
			parsedCommentHash["time_comment"] = get_time_commit_comment(parsedComment[2])
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

	def self.get_time_work_date(parsedTimeComment)
		begin
			return Time.parse(parsedTimeComment).utc
		rescue
			return nil
		end
	end

	def self.get_time_commit_comment(parsedTimeComment)
		return parsedTimeComment.lstrip.gsub("\r\n", " ")
	end

end