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

			self.process_issue(repo, i)



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


		# Tasks Processing BETA code:

		commentBody1 = "Cat\r\n\r\nDog\r\n\r\n- [ ] :clock1: :free: 1h | Task Name 1\r\n- [ ] Task Name 2\r\n\r\n- [ ] Task Name 3\r\n- [x] Tast Complete 1\r\n\r\ncats \r\n\r\n- [x] Task name Complete 1\r\n\r\n\r\n- [ ] Task Name 4"
		dog = self.get_comment_tasks(commentBody1, :incomplete)
		puts dog
		puts self.get_time_from_commment_tasks(dog, :incomplete)


	end


	def process_issue(repo, issueDetails)
		# output = {}
		
		type = "Issue Time"
		issueState = issueDetails.attrs[:state]
		issueTitle = issueDetails.attrs[:title]
		issueNumber = issueDetails.attrs[:number]

		milestoneNumber = get_issue_milestone_number(issueDetails.attrs[:milestone])
		
		labelNames = self.get_label_names(issueDetails.attrs[:labels])
		labels = self.process_issue_labels(labelNames)
		

		issueComments = @ghClient.issue_comments(repo, issueDetails.attrs[:number])

		commentsTime = []
		issueComments.each do |x|
			commentsTime << self.process_issue_comment_for_time(x)
		end
		output = {"type" => type,
				"issue_state" => issueState,
				"issue_title" => issueTitle,
				"issue_number" => issueNumber,
				"milestone_number" => milestoneNumber,
				"labels" => labels,
				"time_commits" => commentsTime}

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





	def time_comment?(commentBody)
		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]

		return acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ }
	end

	def time_comment_non_billable?(commentBody)
		acceptedNonBilliableEmoji = [":free:"]

		return acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
	end

	def get_label_names(labels)
		issueLabels = []
		if labels != nil
			labels.each do |x|
				issueLabels << x["name"]
			end
		end
		return issueLabels
	end

	def get_issue_milestone_number(milestoneDetails)
		if milestoneDetails != nil
			return milestoneDetails.attrs[:number]
		end
	end

	def get_time_duration(durationText)
		return ChronicDuration.parse(durationText)
	end

	def parse_time_commit(timeComment, nonBillableTime)
		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]

		acceptedNonBilliableEmoji = [":free:"]
		parsedCommentHash = {}
		parsedComment = []
		acceptedClockEmoji.each do |x|
			if nonBillableTime == true
				acceptedNonBilliableEmoji.each do |b|
					if timeComment =~ /\A#{x} #{b}/
						parsedComment = self.parse_non_billable_time_comment(timeComment,x,b)
						parsedCommentHash["non_billable"] = true
						break
					end
				end
			elsif nonBillableTime == false
				if timeComment =~ /\A#{x}/
					parsedComment = self.parse_billable_time_comment(timeComment,x)
					parsedCommentHash["non_billable"] = false
					break
				end
			end
		end

		if parsedComment[0] != nil
			parsedCommentHash["duration"] = self.get_time_duration(parsedComment[0])
		end
		if parsedComment[1] != nil
			parsedCommentHash["work_date"] = self.get_time_work_date(parsedComment[1])
		end
		if parsedComment[2] != nil
			parsedCommentHash["time_comment"] = self.get_time_commit_comment(parsedComment[2])
		end

		return parsedCommentHash
	end

	def parse_billable_time_comment(timeComment, timeEmoji)
		return commentBody.gsub("#{timeEmoji} ","").split(" | ")
	end

	def parse_non_billable_time_comment(timeComment, timeEmoji, nonBillableEmoji)
		return commentBody.gsub("#{timeEmoji} #{nonBillableEmoji} ","").split(" | ")
	end

	def get_time_work_date(parsedTimeComment)
		begin
			return Time.parse(parsedTimeComment).utc
		rescue
			return nil
		end
	end

	def get_time_commit_comment(parsedTimeComment)
		return parsedTimeComment.lstrip.gsub("\r\n", " ")
	end


	def process_issue_comment_for_time(issueComment)
		output = {}
		nonBillable = self.time_comment_non_billable?(issueComment)
		parsedTimeDetails = self.parse_time_commit(issueComment, nonBillable)

		overviewDetails = {"comment_id" => issueComment.attrs[:id],
							"work_logged_by" => issueComment.attrs[:user].attrs[:login],
							"comment_created_date" => issueComment.attrs[:created_at],
							"comment_last_updated_date" =>issueComment.attrs[:updated_at],
							"record_creation_date" => Time.now.utc}

		parsedTimeDetails.merge(overviewDetails)
		return parsedTimeDetails
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

			# Check if any of the accepted Clock emoji are in the begining of the comment
			if acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ }

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
					issueLabels = self.process_issue_labels(issueLabels)
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
			if acceptedBudgetEmoji.any? { |w| commentBody =~ /\A#{w}/ }

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
					issueLabels = self.process_issue_labels(issueLabels)
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
			if acceptedBudgetEmoji.any? { |w| commentBody =~ /\A#{w}/ }

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
			if acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ }

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
			timeInCommitMessageYN = acceptedClockEmoji.any? { |w| commitMessage =~ /\A#{w}/ }

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

	def process_issue_labels(ghLabels, options = {})
		output = []
		outputHash = {}
		
		if options[:acceptedLabels] == nil
			# Exaple/Default labels.
			acceptedLabels = [
								{:category => "Priority:", :label => "Low"},
								{:category => "Priority:", :label => "Medium"},
								{:category => "Priority:", :label => "High"},
								{:category => "Size:", :label => "Small"},
								{:category => "Size:", :label => "Medium"},
								{:category => "Size:", :label => "Large"},
								{:category => "Version:", :label => "1.0"},
								{:category => "Version:", :label => "1.5"},
								{:category => "Version:", :label => "2.0"},
								{:category => "Task:", :label => "Medium"},
								{:category => "Size:", :label => "Medium"},
							]
		end

		ghLabels.each do |x|
			if acceptedLabels.any? { |b| [b[:category],b[:label]].join(" ") == x } == true
				acceptedLabels.each do |y|
					if [y[:category], y[:label]].join(" ") == x
						outputHash["Category"] = y[:category][0..-2]
						outputHash["Label"] = y[:label]
						output << outputHash
					end
				end
			else
				outputHash["Category"] = nil
				outputHash["Label"] = x
				output << outputHash
			end
		end
		return output
	end

	def get_comment_tasks (commentBody, taskState = :incomplete)

		tasks = []
		startStringIncomplete = /\-\s\[\s\]\s/
		startStringComplete = /\-\s\[x\]\s/

		endString = /[\r\n]|\z/

		if taskState == :incomplete
			tasksInBody = commentBody.scan(/#{startStringIncomplete}(.*?)#{endString}/)
			tasksInBody.each do |x|
				tasks << x[0]
			end
		elsif taskState == :complete
			tasksInBody = commentBody.scan(/#{startStringComplete}(.*?)#{endString}/)
			tasksInBody.each do |x|
				tasks << x[0]
			end
		end
		return tasks
	end

	def get_time_from_commment_tasks (tasksText, taskState)
		output = []
		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
						":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
						":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
						":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
						":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		acceptedNonBilliableEmoji = [":free:"]


		tasksText.each do |commentBody|

			if acceptedClockEmoji.any? { |w| commentBody =~ /\A#{w}/ } == true
				workDate = nil
				parsedComment = nil
				type = "Task Time"
				recordCreationDate = Time.now.utc

				isNonBilliableTime = acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }

				acceptedClockEmoji.each do |x|
					if commentBody.gsub!("#{x} ","") != nil
						if isNonBilliableTime == true
							acceptedNonBilliableEmoji.each do |b|
								parsedComment = commentBody.gsub("#{x} #{b}","").split(" | ")
								break
							end
						else
							parsedComment = commentBody.gsub("#{x} ","").split(" | ")
							break
						end
					end
				end
				# Parse first value as a duration
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
				taskTimeCommitHash = {"type" => type,
									"duration" => duration,
									"non_billable" => isNonBilliableTime,
									"work_date" => workDate,
									"time_description" => timeComment,
									"tasks_state" => taskState.to_s,
									"record_creation_date" => recordCreationDate
								}
				output << taskTimeCommitHash
			end
		end
		return output
	end

	def time_task_non_billable?(taskBody)
		acceptedNonBilliableEmoji = [":free:"]
		
		return acceptedNonBilliableEmoji.any? { |b| commentBody =~ /#{b}/ }
	end

	def time_task?(taskBody)
		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]

		return acceptedClockEmoji.any? { |w| taskBody =~ /\A#{w}/ }
	end
end

start = GitHubTimeTracking.new
start.controller("StephenOTT/Test1", "USERNAME", "PASSWORD")


