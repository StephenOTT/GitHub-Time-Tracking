require 'octokit'
# require 'sinatra'
require 'pp'
require 'chronic_duration'

	# def gh_Authenticate(username, password)
	# 	@ghClient = Octokit::Client.new(:login => username.to_s, :password => password.to_s, :auto_paginate => true)
	# end

class GitHubTimeTracking


	def track_time
		ghUsername = ""
		ghRepo = "StephenOTT/Test1"
		ghUserOrg = ""
		ghLabels = []
		ghMilestone = ""
		ghBody = ""

		acceptedClockEmoji =[":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		repository = "StephenOTT/Test1"
		issueComments = Octokit.issue_comments(repository, 2)
		
		issueComments.each do |c|
			commentBody = c.attrs[:body]

			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				issueId = c.attrs[:id]
				userCreated = c.attrs[:login]
				createdAt = c.attrs[:created_at]
				updatedAt = c.attrs[:updated_at]
				
				parsedComment = commentBody.delete(":clock1:").strip.split(" | ")
				duration = ChronicDuration.parse(parsedComment[0])
				date = DateTime.parse(parsedComment[1])
				
				puts duration
				puts date
				puts userCreated
				puts created_at
			end
		end
	end
end

start = GitHubTimeTracking.new
start.track_time
		