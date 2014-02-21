# require_relative 'time_tracker/helpers'

# Beta code for getting lists of tasks in issues broken down by each comment

module GH_Task_Lists


	def self.comment_has_tasks?(commentBody)
		tasks = self.get_tasks_from_comment(commentBody)
		if tasks[:incomplete].empty? == true and tasks[:complete].empty? == true
			return false
		else
			return true
		end
	end


	def self.get_comment_details(commentRaw, repo, issueNumber, issueState, issueTitle)

		# commentBody = commentRaw.attrs[:body]
		# rawTasks = get_comment_tasks(commentBody)
		
		# if rawTasks[:complete] == nil and rawTasks[:incomplete] == nil
		# 	return nil
		# end

		# processedTasks = process_comment_task_for_time(rawTasks)
		
		# if processedTasks.empty? == false
			overviewDetails = {	"repo" => repo,
								"issue_number" => issueNumber,
								"issue_title" => issueTitle,
								"issue_state" => issueState,
								"comment_id" => commentRaw.attrs[:id],
								"work_logged_by" => commentRaw.attrs[:user].attrs[:login],
								"comment_created_date" => commentRaw.attrs[:created_at],
								"comment_last_updated_date" =>commentRaw.attrs[:updated_at],
								"record_creation_date" => Time.now.utc,
								}
			return overviewDetails
			
			# mergedHash = processedTasks.merge(overviewDetails)
			# return mergedHash
		# else
			# return nil
		# end
	end

	def self.get_comment_body(commentRaw)
		dog = commentRaw.attrs[:body]
		return dog
	end


	def self.merge_details_and_tasks(overviewDetails, tasks)

		return mergedHash = overviewDetails.merge(tasks)

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