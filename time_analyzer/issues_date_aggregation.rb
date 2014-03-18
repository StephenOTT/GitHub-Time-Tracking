require_relative './mongo'


module Issues_Date_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end





	def self.get_issue_time_day_sum(repo, issueNumber, githubAuthInfo)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{ "$match" => { downloaded_by_username: githubAuthInfo[:username], downloaded_by_userID: githubAuthInfo[:userID] }},
			{"$project" => {type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							issue_state: 1, 
							issue_title: 1, 
							time_tracking_commits:{ workrk
													duration: 1, 
													type: 1, 
													comment_id: 1 }}},
			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$match" => {issue_number: issueNumber.to_i}},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
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

end