require 'octokit'
# require 'sinatra'
require 'pp'
require 'chronic_duration'


class GitHubTimeTracking

	def gh_Authenticate(username, password)
		@ghClient = Octokit::Client.new(:login => username.to_s, :password => password.to_s, :auto_paginate => true)
	end

	def get_issue_time(issueNumber)
		ghUsername = ""
		ghRepo = "StephenOTT/Test1"
		ghUserOrg = ""
		ghLabels = []
		ghMilestone = ""
		ghBody = ""
		timeComment = ""

		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		repository = "StephenOTT/Test1"
		issueComments = @ghClient.issue_comments(repository, issueNumber)
		
		issueComments.each do |c|
			commentBody = c.attrs[:body]

			if acceptedClockEmoji.any? { |w| commentBody =~ /#{w}/ }

				commentId = c.attrs[:id]
				userCreated = c.attrs[:user].attrs[:login]
				createdAt = c.attrs[:created_at]
				updatedAt = c.attrs[:updated_at]

				
				parsedComment = commentBody.gsub(":clock1: ","").split(" | ")
				duration = ChronicDuration.parse(parsedComment[0])
				
				if parsedComment[1].nil?
					date = createdAt
				else
					begin
						date = Time.parse(parsedComment[1]).utc
					rescue
						#do something if invalid
						if parsedComment[1].nil? == false
							timeComment = parsedComment[1].to_s.lstrip
						end
					end
					if parsedComment[2].nil? == false
						timeComment = parsedComment[2].to_s.lstrip
					end
				end
				
				puts "******"
				puts "Duration: #{duration}"
				puts "Work Date: #{date}"
				puts "Description: #{timeComment}"
				# puts "Comment ID: #{commentId}"
				# puts "Work Logged Date: #{createdAt}"
				# puts "Work Logged By: #{userCreated}"
				
			end
		end
	end
end

start = GitHubTimeTracking.new
start.gh_Authenticate("USERNAME", "PASSWORD")
start.get_issue_time(2)
		