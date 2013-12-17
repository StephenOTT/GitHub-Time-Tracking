require 'mongo'
require 'pp'


class GitHubTimeTrackingAnalyzer
	include Mongo


	def controller

		self.mongo_Connect

		puts self.analyze_issue_spent_hours
		puts self.analyze_issue_budget_hours
		puts self.analyze_milestone_budget_hours

	end

	def mongo_Connect
		# MongoDB Database Connect
		@client = MongoClient.new("localhost", 27017)

		# code for working with MongoLab
		# uri = "mongodb://USERNAME:PASSWORD@ds061268.mongolab.com:61268/time_commits"
		# @client = MongoClient.from_uri(uri)

		@db = @client["GitHub-TimeTracking"]

		@collTimeTrackingCommits = @db["TimeTrackingCommits"]
	end

	def analyze_issue_spent_hours
		totalIssueSpentHoursBreakdown = @collTimeTrackingCommits.aggregate([
			{ "$match" => {type: "Issue Time"}},
			{ "$group" => {_id:{repo_name: "$repo_name", 
								type:"$type", 
								issue_number:"$issue_number", 
								issue_state: "$issue_state"}, 
								duration_sum: { "$sum" => "$duration" }, 
								issue_count:{"$sum" =>1}}}
								])
		output = []
		totalIssueSpentHoursBreakdown.each do |x|
			x["_id"]["duration_sum"] = x["duration_sum"]
			x["_id"]["issue_count"] = x["issue_count"]
			output << x["_id"]
		end
		return output
	end

	def analyze_issue_budget_hours
		totalIssueBudgetHoursBreakdown = @collTimeTrackingCommits.aggregate([
			{ "$match" => {type: "Issue Budget"}},
			{ "$group" => {_id:{repo_name: "$repo_name", 
								type:"$type", 
								issue_number:"$issue_number", 
								issue_state: "$issue_state"}, 
								duration_sum: { "$sum" => "$duration" }, 
								issue_count:{"$sum" =>1}}}
								])
		output = []
		totalIssueBudgetHoursBreakdown.each do |x|
			x["_id"]["duration_sum"] = x["duration_sum"]
			x["_id"]["issue_count"] = x["issue_count"]
			output << x["_id"]
		end
		return output
	end

	def analyze_milestone_budget_hours
		totalMilestoneBudgetHoursBreakdown = @collTimeTrackingCommits.aggregate([
			{ "$match" => {type: "Milestone Budget"}},
			{ "$group" => {_id:{repo_name: "$repo_name", 
								type: "$type", 
								milestone_number: "$milestone_number", 
								milestone_state: "$milestone_state"}, 
								duration_sum: { "$sum" => "$duration" }, 
								milestone_count:{"$sum" =>1}}}
								])
		output = []
		totalMilestoneBudgetHoursBreakdown.each do |x|
			x["_id"]["duration_sum"] = x["duration_sum"]
			x["_id"]["milestone_count"] = x["milestone_count"]
			output << x["_id"]
		end
		return output
	end

end

start = GitHubTimeTrackingAnalyzer.new
start.controller
