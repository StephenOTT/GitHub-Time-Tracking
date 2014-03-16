require_relative './mongo'


module Users_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end

	# old name: analyze_user_spent_hours_on_issue
	# get all users time for a issue
	def self.get_users_time_for_issue(repo, issueNumber, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
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

	# get time for a specific user in a specific issue
	def self.get_user_time_for_issue(repo, issueNumber, username, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$match" => { issue_number: issueNumber }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "time_tracking_commits.work_logged_by" => username }},
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



	# get all users time for all issues (and milestones)
	def self.get_users_time_for_issues(repo, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
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

	# get all time for all issues for a specific user
	def self.get_user_time_for_issues(repo, username, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "time_tracking_commits.work_logged_by" => username }},
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




# milestones


	# get all users time for all issues assigned to a specific milestone
	def self.get_users_issue_time_for_milestone(repo, milestoneNumber, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$match" => { milestone_number: milestoneNumber }},
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


	# get time for a specific user accross all issues assigned to a specific milestone
	def self.get_user_time_for_issue(repo, milestoneNumber, username, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$match" => { milestone_number: milestoneNumber }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "time_tracking_commits.work_logged_by" => username }},
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


	# get all time from issues for a specific user for all milestones
	def self.get_user_time_for_issues(repo, username, githubAuthInfo)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "time_tracking_commits.work_logged_by" => username }},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
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