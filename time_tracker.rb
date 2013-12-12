require 'octokit'
# require 'sinatra'
require 'pp'
require 'chronic_duration'
# require 'chronic'


class GitHubTimeTracking

	def gh_Authenticate(username, password)
		@ghClient = Octokit::Client.new(:login => username.to_s, :password => password.to_s, :auto_paginate => true)
	end

	def get_issue_time(repo, issueNumber)
		ghUsername = ""
		ghRepo = "StephenOTT/Test1"
		ghUserOrg = ""
		ghLabels = []
		ghMilestone = ""
		ghBody = ""


		acceptedClockEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
		issueComments = @ghClient.issue_comments(repo, issueNumber)
		
		issueComments.each do |c|
			parsedComment = ""
			timeComment = ""

			commentBody = c.attrs[:body]

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
				duration = ChronicDuration.parse(parsedComment[0])
				
				if parsedComment[1].nil?
					workDate = ""
				else
					begin
						workDate = Time.parse(parsedComment[1]).utc
					rescue
						#do something if invalid
						if parsedComment[1].nil? == false
							timeComment = parsedComment[1].lstrip.gsub("\r\n", " ")
						end
					end
					if parsedComment[2].nil? == false
						timeComment = parsedComment[2].lstrip.gsub("\r\n", " ")
					end
				end
				
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
end

start = GitHubTimeTracking.new
start.gh_Authenticate("USERNAME", "PASSWORD")
start.get_issue_time("StephenOTT/Test1", 2)
		