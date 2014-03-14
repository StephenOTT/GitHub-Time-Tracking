
require_relative './mongo'


module Code_Commit_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end

	# old name: analyze_code_commits_spent_hours
	def self.get_code_commits_time
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							commit_author_username: 1, 
							_id: 1, 
							repo: 1,
							commit_committer_username: 1, 
							commit_sha: 1, 
							commit_message_time:{ duration: 1, 
													type: 1}}},			
			{ "$match" => { type: "Code Commit" }},
			{ "$match" => { commit_message_time: { "$ne" => nil } }},
			{ "$group" => { _id: {
							repo_name: "$repo",
							commit_committer_username: "$commit_committer_username",
							commit_author_username: "$commit_author_username",
							commit_sha: "$commit_sha", },
							time_duration_sum: { "$sum" => "$commit_message_time.duration" }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			output << x["_id"]
		end
		return output
	end

	def self.get_code_commit_time_comments(codeCommitSHA)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1,  
							_id: 1, 
							repo: 1,
							commit_sha: 1, 
							commit_comment_time:{ duration: 1, 
													type: 1 }}},			
			{ "$match" => { type: "Code Commit" }},
			{ "$match" => { commit_sha: codeCommitSHA }},
			{ "$match" => { commit_comment_time: { "$ne" => {"$size" => 0 }}}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							commit_sha: "$commit_sha", 
							type: "$commit_comment_time.type"},
							time_duration_sum: { "$sum" => "$commit_comment_time.duration" },
							time_comment_count: { "$sum" => 1 },
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			output << x["_id"]
		end
		return output
	end

end

# Code_Commit_Aggregation.controller
# puts Code_Commit_Aggregation.get_code_commits_time
# puts Code_Commit_Aggregation.get_code_commit_time_comments("b4f3a58b6e44c6a99fc2fb9a8d27e098d13af45d")