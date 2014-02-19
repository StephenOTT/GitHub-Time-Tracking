require 'octokit'

module GitHub_Data

	def self.gh_authenticate(username, password)
		@ghClient = Octokit::Client.new(
										:login => username.to_s, 
										:password => password.to_s, 
										:auto_paginate => true
										)
	end

	def self.get_Issues(repo)
		issueResultsOpen = @ghClient.list_issues(repo, {
			:state => :open
			})
		issueResultsClosed = @ghClient.list_issues(repo, {
			:state => :closed
			})

		return mergedIssues = issueResultsOpen + issueResultsClosed
	end

	def self.get_Milestones(repo)
		milestonesResultsOpen = @ghClient.list_milestones(repo, {
			:state => :open
			})
		milestonesResultsClosed = @ghClient.list_milestones(repo, {
			:state => :closed
			})

		return mergedMilestones = milestonesResultsOpen + milestonesResultsClosed
	end

	def self.get_Issue_Comments(repo, issueNumber)
		return @ghClient.issue_comments(repo, issueNumber)
	end
end