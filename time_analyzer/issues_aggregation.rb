require_relative './mongo'


module Issues_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end

	# old name: analyze_issue_spent_hours
	def self.get_all_issues_time(repo)
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

	def self.get_issue_time(repo, issueNumber)
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
													comment_id: 1 }}},
			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$match" => {issue_number: issueNumber}},
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




	# old name: analyze_issue_budget_hours
	def self.get_all_issues_budget(repo)
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
													comment_id: 1 }}},
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_state: "$issue_state",
							issue_title: "$issue_title",},
							budget_duration_sum: { "$sum" => "$time_tracking_commits.duration" },
							budget_comment_count: { "$sum" => 1 }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["budget_duration_sum"] = x["budget_duration_sum"]
			x["_id"]["budget_comment_count"] = x["budget_comment_count"]
			output << x["_id"]
		end
		return output
	end


	def self.get_issue_budget(repo, issueNumber)
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
													comment_id: 1 }}},			
			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$match" => {issue_number: issueNumber}},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_state: "$issue_state",
							issue_title: "$issue_title",},
							budget_duration_sum: { "$sum" => "$time_tracking_commits.duration" },
							budget_comment_count: { "$sum" => 1 }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["budget_duration_sum"] = x["budget_duration_sum"]
			x["_id"]["budget_comment_count"] = x["budget_comment_count"]
			output << x["_id"]
		end
		return output
	end




	def self.get_all_issues_time_in_milestone(repo, milestoneNumber)
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



	def self.get_total_issues_time_for_milestone(repo, milestoneNumber)
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
													comment_id: 1 }}},			
			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$match" => { milestone_number: milestoneNumber }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number"},
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





	def self.get_all_issues_budget_in_milestone(repo, milestoneNumber)
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
													comment_id: 1 }}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$match" => { milestone_number: milestoneNumber }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_state: "$issue_state",
							issue_title: "$issue_title",},
							budget_duration_sum: { "$sum" => "$time_tracking_commits.duration" },
							budget_comment_count: { "$sum" => 1 }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["budget_duration_sum"] = x["budget_duration_sum"]
			x["_id"]["budget_comment_count"] = x["budget_comment_count"]
			output << x["_id"]
		end
		return output
	end


	# Get repo sum of issue time
	def self.get_repo_time_from_issues(repo)
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
													comment_id: 1 }}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo"},
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

	# Sums all issue budgets for the repo and outputs the total budget based on issues
	def self.get_repo_budget_from_issues(repo)
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
													comment_id: 1 }}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo"},
							budget_duration_sum: { "$sum" => "$time_tracking_commits.duration" },
							budget_comment_count: { "$sum" => 1 }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["budget_duration_sum"] = x["budget_duration_sum"]
			x["_id"]["budget_comment_count"] = x["budget_comment_count"]
			output << x["_id"]
		end
		return output
	end
end