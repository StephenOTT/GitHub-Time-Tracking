require_relative './mongo'


module Issues_Date_Aggregation

	def self.controller

		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")

	end
	
	# gets the time durations of each repo for a specific yearr brokendown by month
	def self.get_repo_time_month_year_sum(repo, filterYear, githubAuthInfo)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{ "$match" => { downloaded_by_username: githubAuthInfo[:username], downloaded_by_userID: githubAuthInfo[:userID] }},
			{ "$project" => { type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							issue_state: 1, 
							issue_title: 1, 
							time_tracking_commits:{ work_date: 1,
												 duration: 1, 
												 type: 1, 
												 comment_id: 1 }}},

			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$project" => {type: 1, 
							 issue_number: 1, 
							 _id: 1, 
							 repo: 1,
							 milestone_number: 1, 
							 issue_state: 1, 
							 issue_title: 1, 
							 time_tracking_commits:{ work_date_dayOfMonth: {"$dayOfMonth" => "$time_tracking_commits.work_date"}, 
													 work_date_month: {"$month" => "$time_tracking_commits.work_date"}, 
													 work_date_year: {"$year" => "$time_tracking_commits.work_date"}, 
													 work_date: 1,
													 duration: 1, 
													 type: 1, 
													 comment_id: 1 }}},
			{ "$match" => { "time_tracking_commits.work_date_year" => filterYear }},									
			{ "$group" => { _id: {
							repo_name: "$repo",
							# milestone_number: "$milestone_number",
							# issue_number: "$issue_number",
							# issue_title: "$issue_title",
							# issue_state: "$issue_state",
							work_date_month: "$time_tracking_commits.work_date_month",
							work_date_year: "$time_tracking_commits.work_date_year", },
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



	# gets the durations for a specific year for a specific issue number brokendown by month
	def self.get_issue_time_month_year_sum(repo, filterYear, issueNumber, githubAuthInfo)
		totalIssueSpentHoursBreakdown = Mongo_Connection.aggregate_test([
			{ "$match" => { downloaded_by_username: githubAuthInfo[:username], downloaded_by_userID: githubAuthInfo[:userID] }},
			{ "$project" => { type: 1, 
							issue_number: 1, 
							_id: 1, 
							repo: 1,
							milestone_number: 1, 
							issue_state: 1, 
							issue_title: 1, 
							time_tracking_commits:{ work_date: 1,
												 duration: 1, 
												 type: 1, 
												 comment_id: 1 }}},

			{ "$match" => { repo: repo }},			
			{ "$match" => { type: "Issue" }},
			{ "$unwind" => "$time_tracking_commits" },
			{ "$match" => { "time_tracking_commits.type" => { "$in" => ["Issue Time"] }}},
			{ "$project" => {type: 1, 
							 issue_number: 1, 
							 _id: 1, 
							 repo: 1,
							 milestone_number: 1, 
							 issue_state: 1, 
							 issue_title: 1, 
							 time_tracking_commits:{ work_date_dayOfMonth: {"$dayOfMonth" => "$time_tracking_commits.work_date"}, 
													 work_date_month: {"$month" => "$time_tracking_commits.work_date"}, 
													 work_date_year: {"$year" => "$time_tracking_commits.work_date"}, 
													 work_date: 1,
													 duration: 1, 
													 type: 1, 
													 comment_id: 1 }}},
			{ "$match" => { "time_tracking_commits.work_date_year" => filterYear, "issue_number" =>issueNumber }},									
			{ "$group" => { _id: {
							repo_name: "$repo",
							milestone_number: "$milestone_number",
							issue_number: "$issue_number",
							issue_title: "$issue_title",
							issue_state: "$issue_state",
							work_date_month: "$time_tracking_commits.work_date_month",
							work_date_year: "$time_tracking_commits.work_date_year", },
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
Issues_Date_Aggregation.controller
# puts Issues_Date_Aggregation.get_repo_time_month_year_sum("StephenOTT/Test1", 2013, {:username => "StephenOTT", :userID => 1994838})
# puts Issues_Date_Aggregation.get_issue_time_month_year_sum("StephenOTT/Test1", 2013, 8, {:username => "StephenOTT", :userID => 1994838})
