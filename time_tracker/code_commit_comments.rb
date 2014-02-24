require_relative "helpers"

module Commit_Comments

	def self.process_commit_comment_for_time(commitCommentRaw)


		commentBody = commitCommentRaw.attrs[:body]
		nonBillable = Helpers.non_billable?(commentBody)
		parsedTimeDetails = parse_time_commit(commentBody, nonBillable)
		


		commentId = commitCommentRaw.attrs[:id]
		userCreated = commitCommentRaw.attrs[:user].attrs[:login]
		createdAtDate = commitCommentRaw.attrs[:created_at]
		updatedAtDate = commitCommentRaw.attrs[:updated_at]
		
		recordCreationDate = Time.now.utc
		commentForPath = commitCommentRaw.attrs[:path]
		commentForLine = commitCommentRaw.attrs[:line]

		if commentForLine == nil and commentForLine == nil
			type = "Code Commit Comment Time"
		else
			type = "Code Commit Line Comment Time"
		end


		if parsedTimeDetails == nil
			return []
		else
			overviewDetails = {	"type" => type,
								"comment_id" => commentId,
								"comment_created_date" => createdAtDate,
								"work_logged_by" => userCreated,
								"path" => commentForPath,
								"line" => commentForLine,
								"record_creation_date" => Time.now.utc}
			mergedHash = parsedTimeDetails.merge(overviewDetails)
			return mergedHash
		end
	end

	def self.parse_time_commit(timeComment, nonBillableTime)
		acceptedClockEmoji = Helpers.get_Issue_Time_Emoji
		acceptedNonBilliableEmoji = Helpers.get_Non_Billable_Emoji

		parsedCommentHash = { "duration" => nil, "non_billable" => nil, "work_date" => nil, "time_comment" => nil}
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
