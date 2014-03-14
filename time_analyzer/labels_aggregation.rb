require_relative './mongo'

module Labels_Analyzer

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end

	#old method name: analyze_issue_spent_hours_per_label
	def self.get_issues_time_for_label(repo, category, label)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$labels" },
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "labels.category" => category }},
			{ "$match" => { "labels.label" => label }},
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




	def self.get_issues_time_for_label_and_milestone(repo, category, label, milestoneNumber)
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
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Issue" }},
			{ "$match" => { milestone_number: milestoneNumber }},
			{ "$unwind" => "$labels" },
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "labels.category" => category }},
			{ "$match" => { "labels.label" => label }},
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



end