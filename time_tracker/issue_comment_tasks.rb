require_relative 'helpers'
require_relative 'issue_time'

module Gh_Issue_Comment_Tasks

	def self.process_issue_comment_for_task_time(commentRaw)

		type = "Task Time"
		commentBody = commentRaw.attrs[:body]
		rawTasks = get_comment_tasks(commentBody)
		
		if rawTasks[:complete] == nil and rawTasks[:incomplete] == nil
			return nil
		end

		processedTasks = process_comment_task_for_time(rawTasks)
		
		# Checks the hash of arrays items to see if the work date provided YN value is 
		# false and if it is then makes the work date value the same value as the comment 
		# created date
		processedTasks["tasks"].each do |t|
			if t["work_date_provided"] == false
					t["work_date"] = commentRaw.attrs[:created_at]
			end
		end


		
		if processedTasks.empty? == false
			overviewDetails = {"type" => type,
								"comment_id" => commentRaw.attrs[:id],
								"work_logged_by" => commentRaw.attrs[:user].attrs[:login],
								"comment_created_date" => commentRaw.attrs[:created_at],
								"comment_last_updated_date" =>commentRaw.attrs[:updated_at],
								"record_creation_date" => Time.now.utc}
			
			mergedHash = processedTasks.merge(overviewDetails)
			return mergedHash
		else
			return nil
		end
	end

	def self.get_comment_tasks(commentBody)

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

	def self.process_comment_task_for_time(tasks)
		finalTasks = []

		tasks[:complete].each do |t|
			nonBillable = Helpers.non_billable?(t)
			parsedTimeDetails = Gh_Issue_Time.parse_time_commit(t, nonBillable)

			if parsedTimeDetails != nil
				parsedTimeDetails["task_status"] = "complete"
				finalTasks << parsedTimeDetails
			end
		end

		tasks[:incomplete].each do |t|
			nonBillable = Helpers.non_billable?(t)
			parsedTimeDetails = Gh_Issue_Time.parse_time_commit(t, nonBillable)
			
			if parsedTimeDetails != nil
				parsedTimeDetails["task_status"] = "incomplete"
				finalTasks << parsedTimeDetails
			end
		end
		tasksHash = {"tasks" => finalTasks}

		return tasksHash
	end


end
