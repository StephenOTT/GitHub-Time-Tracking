require_relative './mongo'


module Milestones_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end



	# old names: self.analyze_milestones
	def self.get_all_milestones_budget(repo)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							milestone_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_state: 1, 
							milestone_title: 1, 
							milestone_open_issue_count: 1,
							milestone_closed_issue_count: 1,
							budget_tracking_commits:{ duration: 1, 
													  type: 1}}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Milestone" }},
			{ "$unwind" => "$budget_tracking_commits" },
			{ "$match" => { "budget_tracking_commits.type" => { "$in" => ["Milestone Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							milestone_state: "$milestone_state",
							milestone_title: "$milestone_title",
							milestone_open_issue_count: "$milestone_open_issue_count",
							milestone_closed_issue_count: "$milestone_closed_issue_count",},
							milestone_duration_sum: { "$sum" => "$budget_tracking_commits.duration" }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["milestone_duration_sum"] = x["milestone_duration_sum"]
			output << x["_id"]
		end
		return output
	end


	def self.get_milestone_budget(repo, milestoneNumber)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							milestone_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_state: 1, 
							milestone_title: 1, 
							milestone_open_issue_count: 1,
							milestone_closed_issue_count: 1,
							budget_tracking_commits:{ duration: 1, 
													  type: 1}}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Milestone" }},
			{ "$match" => { milestone_number: milestoneNumber }},
			{ "$unwind" => "$budget_tracking_commits" },
			{ "$match" => { "budget_tracking_commits.type" => { "$in" => ["Milestone Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							milestone_state: "$milestone_state",
							milestone_title: "$milestone_title",
							milestone_open_issue_count: "$milestone_open_issue_count",
							milestone_closed_issue_count: "$milestone_closed_issue_count",},
							milestone_duration_sum: { "$sum" => "$budget_tracking_commits.duration" }
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["milestone_duration_sum"] = x["milestone_duration_sum"]
			output << x["_id"]
		end
		return output
	end

	# Gets the sum of all milestones budgets for a repo
	def self.get_repo_budget_from_milestones(repo)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							milestone_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_state: 1, 
							milestone_title: 1, 
							milestone_open_issue_count: 1,
							milestone_closed_issue_count: 1,
							budget_tracking_commits:{ duration: 1, 
													  type: 1}}},			
			{ "$match" => { repo: repo }},
			{ "$match" => { type: "Milestone" }},
			{ "$unwind" => "$budget_tracking_commits" },
			{ "$match" => { "budget_tracking_commits.type" => { "$in" => ["Milestone Budget"] }}},
			{ "$group" => { _id: {
							repo_name: "$repo"},
							milestone_duration_sum: { "$sum" => "$budget_tracking_commits.duration" },
							milestone_state: { "$sum" => 1 },
							}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["milestone_duration_sum"] = x["milestone_duration_sum"]
			output << x["_id"]
		end
		return output
	end
end