require 'octokit'
# require 'sinatra'
require 'pp'
require 'chronic_duration'
# require 'chronic'
require 'mongo'

class GitHubTimeTracking
	include Mongo

	def controller(repo, username, password)
		self.gh_Authenticate(username, password)
		self.mongo_Connect

		@collTimeCommits.remove
		@collBudgetCommits.remove

		issues = self.get_Issues(repo)

		issues.each do |i|
			issueNumber = i.attrs[:number]
			self.get_issue_time(repo, issueNumber)
			self.get_issue_budget(repo,issueNumber)
		end
	end

	def get_Issues(repo)
		issueResultsOpen = @ghClient.list_issues(repo, {
			:state => :open
			})
		issueResultsClosed = @ghClient.list_issues(repo, {
			:state => :closed
			})

		return mergedIssues = issueResultsOpen + issueResultsClosed
	end

	def get_milestone_budget (repo, milestones = nil)
		
		if milestones == nil
			milestones = self.get_Milestones(repo)
		end

		acceptedBudgetEmoji = [":dart:"]
		
		# Cycle through each milestone
		milestones.each do |c|
			parsedDescription = []
			budgetComment = ""

			commentBody = c.attrs[:description]

			# Check if any of the accepted emoji are in the comment
			if acceptedBudgetEmoji.any? { |w| commentBody =~ /#{w}/ }

				milestoneTitle = c.attrs[:title]
				milestoneNumber = c.attrs[:number]
				createdAtDate = c.attrs[:created_at]
				milestoneState = c.attrs[:state]
				milestoneDueDate = c.attrs[:due_on]
				type = "Milestone Budget"
				recordCreationDate = Time.now.utc



				acceptedBudgetEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						parsedDescription = commentBody.gsub("#{x} ","").split(" | ")
					end
				end
				# Parse first value as a duration
				# TODO add error catching for improper duration format.
				duration = ChronicDuration.parse(parsedDescription[0])
				
				if parsedDescription[1].nil? == false
					budgetComment = parsedDescription[1].lstrip.gsub("\r\n", " ")
				end
				
				timeCommitHash = {"type" => type,
									"druration" => duration,
									"milestone_due_date" => milestoneDueDate,
									"time_description" => budgetComment,
									"milestone_number" => milestoneNumber,
									"milestone_created_date" => createdAtDate,
									"repo_name" => repo,
									"milestone_state" => milestoneState,
									"milestone_title" => milestoneTitle,
									"record_creation_date" => recordCreationDate
								}
				self.putIntoMongoCollTimeCommits(timeCommitHash)
				puts "******"
				puts "Type: #{type}"
				puts "Milestone Title: #{milestoneTitle}"
				puts "Duration: #{duration}"
				puts "Milestone Due Date: #{milestoneDueDate}"
				puts "Description: #{budgetComment}"
				puts "Milestone Number: #{milestoneNumber}"
				puts "Milestone Created Date: #{createdAtDate}"
				puts "Repo Name: #{repo}"
				puts "Milestone State: #{milestoneState}"
				puts "Record Creation Date: #{recordCreationDate}"
			end
		end
	end 



	def mongo_Connect
		# MongoDB Database Connect
		@client = MongoClient.new("localhost", 27017)
		@db = @client["GitHub-TimeCommits"]

		@collTimeCommits = @db["TimeCommits"]
		@collBudgetCommits = @db["BudgetCommits"]
	end

	def putIntoMongoCollTimeCommits(mongoPayload)
		@collTimeCommits.insert(mongoPayload)
	end

	def putIntoMongoCollBudgetCommits(mongoPayload)
		@collBudgetCommits.insert(mongoPayload)
	end

	def gh_Authenticate(username, password)
		@ghClient = Octokit::Client.new(:login => username.to_s, :password => password.to_s, :auto_paginate => true)
	end

	def get_issue_time(repo, issueNumber)

		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		issueComments = @ghClient.issue_comments(repo, issueNumber)
		
		# Cycle through each comment in the issue
		issueComments.each do |c|
			parsedComment = ""
			timeComment = ""

			commentBody = c.attrs[:body]

			# Check if any of the accepted Clock emoji are in the comment
			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAtDate = c.attrs[:created_at]
				updatedAtDate = c.attrs[:updated_at]

				acceptedClockEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						parsedComment = commentBody.gsub("#{x} ","").split(" | ")
					end
				end
				# Parse first value as a duration
				# TODO add support for duration not be parsed correctly. (use case is that the clock emoji is used in a regular comment that is not part of a time commit)
				duration = ChronicDuration.parse(parsedComment[0])
				
				# Is there anything more than a duration value?
				if parsedComment[1].nil?
					workDate = ""
				else
					begin
						# Determine if the second item is a Date.
						# Try to parse the item as a Date
						workDate = Time.parse(parsedComment[1]).utc
					rescue
						# If date parse is invalid then we assume second item is not a date
						# We assume it is not a date then it is treated as a comment
						if parsedComment[1].nil? == false
							timeComment = parsedComment[1].lstrip.gsub("\r\n", " ")
						end
					end
					# if there is a Druation and a Date then there will be a third item in the array
					# If there is a third item then we treat it as a comment
					if parsedComment[2].nil? == false
						timeComment = parsedComment[2].lstrip.gsub("\r\n", " ")
					end
				end
				
				timeCommitHash = {"druration" => duration,
									"work_date" => workDate,
									"time_description" => timeComment,
									"comment_id" => commentId,
									"comment_created_date" => createdAtDate,
									"work_logged_by" => userCreated,
									"issue_id" => issueNumber,
									"repo_name" => repo
								}
				self.putIntoMongoCollTimeCommits(timeCommitHash)
				puts "******"
				puts "Duration: #{duration}"
				puts "Work Date: #{workDate}"
				puts "Description: #{timeComment}"
				puts "Comment ID: #{commentId}"
				puts "Comment Created Date: #{createdAtDate}"
				puts "Work Logged By: #{userCreated}"
				puts "Issue ID: #{issueNumber}"
				puts "Repo Name: #{repo}"
			end
		end
	end

	def get_issue_budget(repo, issueNumber)

		acceptedClockEmoji = [":dart:"]
		issueComments = @ghClient.issue_comments(repo, issueNumber)
		
		# Cycle through each comment in the issue
		issueComments.each do |c|
			parsedComment = ""
			budgetComment = ""

			commentBody = c.attrs[:body]

			# Check if any of the accepted emoji are in the comment
			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAtDate = c.attrs[:created_at]
				updatedAtDate = c.attrs[:updated_at]

				acceptedClockEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						parsedComment = commentBody.gsub("#{x} ","").split(" | ")
					end
				end

				budgetDuration = ChronicDuration.parse(parsedComment[0])
				
				if parsedComment[1].nil? == false
					budgetComment = parsedComment[1].lstrip.gsub("\r\n", " ")
				end
				
				budgetCommitHash = {"budget_druration" => budgetDuration,
									"budget_description" => budgetComment,
									"comment_id" => commentId,
									"comment_created_date" => createdAtDate,
									"budget_logged_by" => userCreated,
									"issue_id" => issueNumber,
									"repo_name" => repo
								}
				self.putIntoMongoCollBudgetCommits(budgetCommitHash)
				puts "******"
				puts "Budget Duration: #{budgetDuration}"
				puts "Budget Description: #{budgetComment}"
				puts "Comment ID: #{commentId}"
				puts "Comment Created Date: #{createdAtDate}"
				puts "Work Logged By: #{userCreated}"
				puts "Issue ID: #{issueNumber}"
				puts "Repo Name: #{repo}"

			end
		end
	end
end

start = GitHubTimeTracking.new
start.controller("StephenOTT/Test1", "USERNAME", "PASSWORD")




		