require_relative './mongo'

module Time_Analyzer

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end



	# TODO: Review code for better structure.
	# TODO: Review code to work out problematic selections.  
	# Not 100% sure this query wont cause bad results in certain situations.
	def self.analyze_issue_spent_hours_per_label(category, label)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							issue_state: 1, 
							issue_title: 1, 
							time_tracking_commits: { duration: 1, 
													type: 1, 
													comment_id: 1 },
							labels: { category: 1,
									  label: 1 },
													}},			
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$labels" },
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "labels.category" => { "$in" => category }}},
			{ "$match" => { "labels.label" => { "$in" => label }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							category: "$labels.category",
							label: "$labels.label",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_title: "$issue_title",
							issue_state: "$issue_state", },
							time_duration_sum: { "$sum" => "$time_tracking_commits.duration" },
							time_comment_count: { "$sum" => 1 }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			x["_id"]["time_comment_count"] = x["time_comment_count"]
			output << x["_id"]
		end
		return output
	end



	def self.analyze_code_commits_spent_hours
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

	def self.budget_left?(large, small)
		large - small
	end



end


# DEBUG CODE for testing output of methods without the need of Sinatra.

# Time_Analyzer.controller

# puts Time_Analyzer.analyze_issue_spent_hours_per_user
# puts Time_Analyzer.analyze_issue_spent_hours_per_milestone(1)
# puts Time_Analyzer.analyze_issue_spent_hours_per_label(["Priority"], ["High", "Medium"])
# puts Time_Analyzer.analyze_code_commits_spent_hours
# puts Time_Analyzer.analyze_issue_spent_hours_for_milestone([1])

