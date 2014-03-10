require_relative './mongo'


module Users_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end

	def self.analyze_user_spent_hours_on_issue(issueNumber)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							issue_state: 1, 
							issue_title: 1,
							time_tracking_commits:{ duration: 1, 
													type: 1,
													work_logged_by: 1,  
													comment_id: 1 }}},			
			{ "$match" => { type: "Issue" }},
			{ "$match" => { issue_number: issueNumber }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_title: "$issue_title",
							issue_state: "$issue_state", 
							work_logged_by: "$time_tracking_commits.work_logged_by"},
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

# Debug code
# Users_Aggregation.controller
# puts Users_Aggregation.analyze_user_spent_hours_on_issue(8)



