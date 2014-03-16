require_relative './mongo'

module System_Wide_Aggregation

	def self.controller
		Mongo_Connection.mongo_Connect("localhost", 27017, "GitHub-TimeTracking", "TimeTrackingCommits")
	end

	def self.get_all_repos_assigned_to_logged_user(githubAuthInfo)
		reposAssignedToLoggedUser = Mongo_Connection.aggregate_test([
			{ "$match" => { downloaded_by_username: githubAuthInfo[:username], downloaded_by_userID: githubAuthInfo[:userID] }},
			{"$project" => {_id: 1, 
							repo: 1}},			
			{ "$group" => { _id: {
							repo_name: "$repo"
							}}}
							])


		output = []
		reposAssignedToLoggedUser.each do |x|
			toParseString = x["_id"]["repo_name"]
			x["_id"]["username"] = toParseString.partition("/").first
			x["_id"]["repo_name"] = toParseString.partition("/").last
			x["_id"]["repo_name_full"] = toParseString
			output << x["_id"]
		end
		return output
	end
end

# Debug code
# System_Wide_Aggregation.controller
# puts System_Wide_Aggregation.get_all_repos_assigned_to_logged_user({:username => "StephenOTT", :userID => 1994838})