require_relative './mongo'


module Milestones_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end



	# old names: self.analyze_milestones
	def self.get_milestones
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

	# old name: analyze_issue_spent_hours_for_milestone
	# Adds up the hours spent on issues for a specific milestone
	def self.get_total_issue_hours_for_milestone(milestoneNumber)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							time_tracking_commits:{ duration: 1, 
													type: 1, 
													comment_id: 1 }}},			
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "milestone_number" => { "$in" => milestoneNumber }}},			
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number"},
							time_duration_sum: { "$sum" => "$time_tracking_commits.duration" }}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			# x["_id"]["time_comment_count"] = x["time_comment_count"]
			output << x["_id"]
		end
		return output
	end



	# totals the hours spent for all issues for a Single Milestone.
	# old name: analyze_issue_spent_hours_for_milestone
	def self.get_total_issue_hours_spent_on_milestone(milestoneNumber)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{"$project" => {type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							time_tracking_commits:{ duration: 1, 
													type: 1, 
													comment_id: 1 }}},			
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$match" => { "milestone_number" => { "$in" => milestoneNumber }}},			
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number"},
							time_duration_sum: { "$sum" => "$time_tracking_commits.duration" }}}
							])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["time_duration_sum"] = x["time_duration_sum"]
			# x["_id"]["time_comment_count"] = x["time_comment_count"]
			output << x["_id"]
		end
		return output
	end
end