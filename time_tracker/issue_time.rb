require_relative 'helpers'

module Gh_Issue_Time

	# processes a comment for time comment information
	def self.process_issue_comment_for_time(issueComment)

		type = "Issue Time"
		issueCommentBody = issueComment.attrs[:body]
		nonBillable = Helpers.non_billable?(issueCommentBody)
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
		acceptedClockEmoji = Helpers.get_Issue_Time_Emoji
		acceptedNonBilliableEmoji = Helpers.get_Non_Billable_Emoji

		parsedCommentHash = { "duration" => nil, "non_billable" => nil, "work_date" => nil, "time_comment" => nil, "work_date_provided" => false}
		parsedComment = []
		
		acceptedClockEmoji.each do |x|
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
			workDate = Helpers.get_time_work_date(parsedComment[1])
				if workDate != nil
					parsedCommentHash["work_date"] = workDate
				elsif workDate == nil
					parsedCommentHash["time_comment"] = Helpers.get_time_commit_comment(parsedComment[1])
				end
		end

		if parsedComment[2] != nil
			parsedCommentHash["time_comment"] = Helpers.get_time_commit_comment(parsedComment[2])
		end

		return parsedCommentHash
	end
end