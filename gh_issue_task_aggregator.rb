# require_relative 'time_tracker/helpers'

# Beta code for getting lists of tasks in issues broken down by each comment

module GH_Issue_Task_Aggregator

	def self.comment_has_tasks?(commentBody)
		tasks = self.get_tasks_from_comment(commentBody)
		if tasks[:incomplete].empty? == true and tasks[:complete].empty? == true
			return false
		else
			return true
		end
	end

	def self.get_issue_details(repo, issueDetailsRaw)
		issueDetails = { "repo" => repo,
						 "issue_number" => issueDetailsRaw.attrs[:number],
						 "issue_title" => issueDetailsRaw.attrs[:title],
						 "issue_state" => issueDetailsRaw.attrs[:state],
						 }
	end

	def self.get_comment_details(commentDetailsRaw)
		overviewDetails = {	"comment_id" => commentDetailsRaw.attrs[:id],
							"comment_created_by" => commentDetailsRaw.attrs[:user].attrs[:login],
							"comment_created_date" => commentDetailsRaw.attrs[:created_at],
							"comment_last_updated_date" =>commentDetailsRaw.attrs[:updated_at],
							"record_creation_date" => Time.now.utc,
							}
	end

	def self.get_comment_body(commentDetailsRaw)
		body = commentDetailsRaw.attrs[:body]
	end


	def self.merge_details_and_tasks(overviewDetails, tasks)
		mergedHash = overviewDetails.merge(tasks)
	end

	def self.get_tasks_from_comment(commentBody)

		tasks = {:complete => nil, :incomplete => nil }
		completeTasks = []
		incompleteTasks = []

		startStringIncomplete = /\-\s\[\s\]\s/
		startStringComplete = /\-\s\[x\]\s/

		endString = /[\r\n]|\z/

		tasksInBody = commentBody.scan(/#{startStringIncomplete}(.*?)#{endString}/)
		tasksInBody.each do |x|
			incompleteTasks << x[0]
		end

		tasksInBody = commentBody.scan(/#{startStringComplete}(.*?)#{endString}/)
		tasksInBody.each do |x|
			completeTasks << x[0]
		end

		tasks[:complete] = completeTasks
		tasks[:incomplete] = incompleteTasks

		return tasks
	end

	def self.add_task_status(tasks)
		finalTasks = []

		tasks[:complete].each do |t|
				parsedTimeDetails["task_status"] = "complete"
				finalTasks << parsedTimeDetails
		end

		tasks[:incomplete].each do |t|
				parsedTimeDetails["task_status"] = "incomplete"
				finalTasks << parsedTimeDetails
		end
		return finalTasks
	end
end