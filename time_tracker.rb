require 'octokit'
require 'chronic_duration'
require 'mongo'

class GitHubTimeTracking
	include Mongo

	def controller(repo, username, password)
		self.gh_Authenticate(username, password)
		self.mongo_Connect

		@collTimeTrackingCommits.remove

		issues = self.get_Issues(repo)
		issues.each do |i|
			issueNumber = i.attrs[:number]

			issueTime = self.get_issue_time(repo, issueNumber)
			issueBudget = self.get_issue_budget(repo, issueNumber)
			if issueTime.empty? == false
				self.putIntoMongoCollTimeTrackingCommits(issueTime)
			end
			if issueBudget.empty? == false
				self.putIntoMongoCollTimeTrackingCommits(issueBudget)
			end	
		end

		milestoneBudgets = self.get_milestone_budget(repo)
		repoCommits = self.get_commits_messages(repo)
		if milestoneBudgets.empty? == false
			self.putIntoMongoCollTimeTrackingCommits(milestoneBudgets)
		end
		if repoCommits.empty? == false
			self.putIntoMongoCollTimeTrackingCommits(repoCommits)
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

	def get_Milestones(repo)
		milestonesResultsOpen = @ghClient.list_milestones(repo, {
			:state => :open
			})
		milestonesResultsClosed = @ghClient.list_milestones(repo, {
			:state => :closed
			})

		return mergedMilestones = milestonesResultsOpen + milestonesResultsClosed
	end

	def mongo_Connect
		# MongoDB Database Connect
		@client = MongoClient.new("localhost", 27017)

		# code for working with MongoLab
		# uri = "mongodb://USERNAME:PASSWORD@ds061268.mongolab.com:61268/TimeTrackingCommits"
		# @client = MongoClient.from_uri(uri)

		@db = @client["GitHub-TimeTracking"]

		@collTimeTrackingCommits = @db["TimeTrackingCommits"]
	end

	def putIntoMongoCollTimeTrackingCommits(mongoPayload)
		@collTimeTrackingCommits.insert(mongoPayload)
	end

	def gh_Authenticate(username, password)
		@ghClient = Octokit::Client.new(:login => username.to_s, :password => password.to_s, :auto_paginate => true)
	end

	def get_issue_time(repo, issueNumber)
		output = []
		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		acceptedNonBilliableEmoji = [":free:"]
		issueComments = @ghClient.issue_comments(repo, issueNumber)
		issueDetails = @ghClient.issue(repo, issueNumber)
		
		# Cycle through each comment in the issue
		issueComments.each do |c|
			parsedComment = nil
			timeComment = nil
			assignedMilestoneNumber = nil

			commentBody = c.attrs[:body]

			# Check if any of the accepted Clock emoji are in the comment
			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAtDate = c.attrs[:created_at]
				updatedAtDate = c.attrs[:updated_at]
				issueState = issueDetails[:state]
				issueTitle = issueDetails[:title]
				type = "Issue Time"
				recordCreationDate = Time.now.utc

				issueLabels = []
				if issueDetails[:labels] !=nil
					issueDetails[:labels].each do |x|
						issueLabels << x["name"]
					end
				end


				if issueDetails[:milestone] != nil
					assignedMilestoneNumber = issueDetails[:milestone].attrs[:number]
				end

				acceptedClockEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedComment = commentBody.gsub("#{x} #{b}","").split(" | ")
							end
						else
							parsedComment = commentBody.gsub("#{x} ","").split(" | ")
						end
					end
				end
				# Parse first value as a duration
				# TODO add support for duration not be parsed correctly. (use case is that the clock emoji is used in a regular comment that is not part of a time commit)
				duration = ChronicDuration.parse(parsedComment[0])
				
				# Is there anything more than a duration value?
				if parsedComment[1].nil?
					workDate = nil
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
				
				timeCommitHash = {"type" => type,
									"duration" => duration,
									"non_billable" => isNonBilliableTime,
									"work_date" => workDate,
									"time_description" => timeComment,
									"comment_id" => commentId,
									"comment_created_date" => createdAtDate,
									"work_logged_by" => userCreated,
									"issue_number" => issueNumber,
									"repo_name" => repo,
									"issue_title" => issueTitle,
									"issue_state" => issueState,
									"assigned_milestone_number" => assignedMilestoneNumber,
									"issue_labels" => issueLabels,
									"record_creation_date" => recordCreationDate
								}
				output << timeCommitHash
			end
		end
		return output
	end

	def get_issue_budget(repo, issueNumber)

		output = []
		acceptedBudgetEmoji = [":dart:"]
		acceptedNonBilliableEmoji = [":free:"]
		issueComments = @ghClient.issue_comments(repo, issueNumber)
		issueDetails = @ghClient.issue(repo, issueNumber)
		
		# Cycle through each comment in the issue
		issueComments.each do |c|
			parsedComment = nil
			budgetComment = nil
			assignedMilestoneNumber = nil

			commentBody = c.attrs[:body]

			# Check if any of the accepted emoji are in the comment
			if acceptedBudgetEmoji.any? { |w| commentBody =~ /#{w}/ }

				isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAtDate = c.attrs[:created_at]
				updatedAtDate = c.attrs[:updated_at]
				issueState = issueDetails[:state]
				issueTitle = issueDetails[:title]
				type = "Issue Budget"
				recordCreationDate = Time.now.utc

				issueLabels = []
				if issueDetails[:labels] !=nil
					issueDetails[:labels].each do |x|
						issueLabels << x["name"]
					end
				end

				if issueDetails[:milestone] != nil
					assignedMilestoneNumber = issueDetails[:milestone].attrs[:number]
				end

				acceptedBudgetEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedComment = commentBody.gsub("#{x} #{b}","").split(" | ")
							end
						else
							parsedComment = commentBody.gsub("#{x} ","").split(" | ")
						end
					end
				end

				budgetDuration = ChronicDuration.parse(parsedComment[0])
				
				if parsedComment[1].nil? == false
					budgetComment = parsedComment[1].lstrip.gsub("\r\n", " ")
				end
				
				budgetCommitHash = {"type" => type,
									"duration" => budgetDuration,
									"non_billable" => isNonBilliableTime,
									"budget_description" => budgetComment,
									"comment_id" => commentId,
									"comment_created_date" => createdAtDate,
									"budget_logged_by" => userCreated,
									"issue_number" => issueNumber,
									"repo_name" => repo,
									"issue_state" => issueState,
									"issue_title" => issueTitle,
									"assigned_milestone_number" => assignedMilestoneNumber,
									"issue_labels" => issueLabels,
									"record_creation_date" => recordCreationDate
								}
				output << budgetCommitHash
			end
		end
		return output
	end

	def get_milestone_budget (repo, milestones = nil)
		
		output = []
		if milestones == nil
			milestones = self.get_Milestones(repo)
		end

		acceptedBudgetEmoji = [":dart:"]
		acceptedNonBilliableEmoji = [":free:"]
		
		# Cycle through each milestone
		milestones.each do |c|
			parsedDescription = []
			budgetComment = nil

			commentBody = c.attrs[:description]

			# Check if any of the accepted emoji are in the comment
			if acceptedBudgetEmoji.any? { |w| commentBody =~ /#{w}/ }

				isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
				milestoneTitle = c.attrs[:title]
				milestoneNumber = c.attrs[:number]
				createdAtDate = c.attrs[:created_at]
				milestoneState = c.attrs[:state]
				milestoneDueDate = c.attrs[:due_on]
				type = "Milestone Budget"
				recordCreationDate = Time.now.utc

				acceptedBudgetEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedDescription = commentBody.gsub("#{x} #{b}","").split(" | ")
							end
						else
							parsedDescription = commentBody.gsub("#{x} ","").split(" | ")
						end
					end
				end

				# Parse first value as a duration
				# TODO add error catching for improper duration format.
				duration = ChronicDuration.parse(parsedDescription[0])
				
				if parsedDescription[1].nil? == false
					budgetComment = parsedDescription[1].lstrip.gsub("\r\n", " ")
				end
				
				milestoneBudgetHash = {"type" => type,
									"duration" => duration,
									"non_billable" => isNonBilliableTime,
									"milestone_due_date" => milestoneDueDate,
									"budget_description" => budgetComment,
									"milestone_number" => milestoneNumber,
									"milestone_created_date" => createdAtDate,
									"repo_name" => repo,
									"milestone_state" => milestoneState,
									"milestone_title" => milestoneTitle,
									"record_creation_date" => recordCreationDate
								}
				output << milestoneBudgetHash
			end
		end
		return output
	end 

	def get_commit_comments(repo, sha)

		commitComments = @ghClient.commit_comments(repo, sha)
		commitCommentsArray = []

		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		acceptedNonBilliableEmoji = [":free:"]
		
		# Cycle through each comment in the issue
		commitComments.each do |c|
			parsedComment = nil
			timeComment = nil

			commentBody = c.attrs[:body]

			# Check if any of the accepted Clock emoji are in the comment
			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAtDate = c.attrs[:created_at]
				updatedAtDate = c.attrs[:updated_at]
				type = "Code Commit Comment Time"
				recordCreationDate = Time.now.utc
				commentForPath = c.attrs[:path]
				commentForLine = c.attrs[:line]

				acceptedClockEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedComment = commentBody.gsub("#{x} #{b}","").split(" | ")
							end
						else
							parsedComment = commentBody.gsub("#{x} ","").split(" | ")
						end
					end
				end

				# Parse first value as a duration
				# TODO add support for duration not be parsed correctly. (use case is that the clock emoji is used in a regular comment that is not part of a time commit)
				duration = ChronicDuration.parse(parsedComment[0])
				
				# Is there anything more than a duration value?
				if parsedComment[1].nil?
					workDate = nil
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
				
				timeCommitHash = {"type" => type,
									"duration" => duration,
									"non_billable" => isNonBilliableTime,
									"work_date" => workDate,
									"time_description" => timeComment,
									"comment_id" => commentId,
									"comment_created_date" => createdAtDate,
									"work_logged_by" => userCreated,
									"path" => commentForPath,
									"line" => commentForLine,
									"record_creation_date" => recordCreationDate
								}
				commitCommentsArray << timeCommitHash
			end
		end
		return commitCommentsArray
	end

	def get_commits_messages(repo, *ghOptions)

		output = []
		repoCommits = @ghClient.commits(repo, ghOptions)

		repoCommits.each do |c|

			acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
									":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
									":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
									":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
									":clock4:", ":clock530:", ":clock7:", ":clock830:"]
			acceptedNonBilliableEmoji = [":free:"]

			parsedComment = nil
			timeComment = nil
			commitParentsShas = []

			commitSha = c.attrs[:sha]
			commitComments = self.get_commit_comments(repo, commitSha)			
			commitMessage = c.attrs[:commit].attrs[:message]

			# Check if any of the accepted Clock emoji are in the comment
			timeInCommitMessageYN = acceptedClockEmoji.any? { |w| commitMessage =~ /#{w}/ }

			type = "Code Commit Time"
			recordCreationDate = Time.now.utc

			commitAuthorUsername = c.attrs[:author].attrs[:login]
			commitAuthorDate =  c.attrs[:commit].attrs[:author].attrs[:date]
			commitCommitterUsername =  c.attrs[:committer].attrs[:login]
			commitCommitterDate = c.attrs[:commit].attrs[:committer].attrs[:date]
			commitTreeSha = c.attrs[:commit].attrs[:tree].attrs[:sha]
			if c.attrs[:parents] != nil
				c.attrs[:parents].each do |x|
					commitParentsShas << x.attrs[:sha]
				end
			end
			isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commitMessage =~ /#{b}/ }
				
			if timeInCommitMessageYN == true
				acceptedClockEmoji.each do |x|
					if commitMessage.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedComment = commitMessage.gsub("#{x} #{b}","").split(" | ")
							end
						else
							parsedComment = commitMessage.gsub("#{x} ","").split(" | ")
						end
					end
				end

				duration = ChronicDuration.parse(parsedComment[0])
				
				# Is there anything more than a duration value?
				if parsedComment[1].nil?
					workDate = nil
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
			end
				
			timeCommitHash = {"type" => type,
								"repo_name" => repo,
								"duration" => duration,
								"non_billable" => isNonBilliableTime,
								"work_date" => workDate,
								"commit_message" => timeComment,
								"commit_author_username" => commitAuthorUsername,
								"commit_author_date" => commitAuthorDate,
								"commit_committer_username" => commitCommitterUsername,
								"commit_committer_date" => commitCommitterDate,
								"commit_sha" => commitSha,
								"commit_tree_sha" => commitTreeSha,
								"commit_parents_shas" => commitParentsShas,
								"commit_comments" => commitComments
							}

			unless timeCommitHash["duration"] == nil and timeCommitHash["commit_comments"].empty? == true
				output << timeCommitHash
			end
		end
		return output
	end
end

start = GitHubTimeTracking.new
start.controller("StephenOTT/Test1", "USERNAME", "PASSWORD")


