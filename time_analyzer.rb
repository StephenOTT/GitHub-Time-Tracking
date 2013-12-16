require 'mongo'
require 'pp'


class GitHubTimeTrackingAnalyzer
	include Mongo


	def controller

		self.mongo_Connect

	end

	def mongo_Connect
		# MongoDB Database Connect
		@client = MongoClient.new("localhost", 27017)

		# code for working with MongoLab
		# uri = "mongodb://USERNAME:PASSWORD@ds061268.mongolab.com:61268/time_commits"
		# @client = MongoClient.from_uri(uri)

		@db = @client["time_commits"]

		@collTimeTrackingCommits = @db["TimeTrackingCommits"]
	end


	def analyze_issue_total_hours
		# totalHoursBreakdown = @collIssues.aggregate([
		# 	{ "$match" => {type: "Issue Comment"}},
		#     { "$unwind" => "$comments_Text" },		
		# 	{ "$match" => {created_year: yearSpan}},
		# 	{ "$group" => {_id:{"created_week" => "$created_week", "created_year" => "$created_year"}, number: { "$sum" => 1 }}},
		# ])


	end




end