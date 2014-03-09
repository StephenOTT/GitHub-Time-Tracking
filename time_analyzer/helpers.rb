require 'chronic_duration'

module Helpers

	def self.budget_left?(large, small)
		large - small
	end

	def self.convertSecondsToDurationFormat(timeInSeconds, outputFormat)
		outputFormat = outputFormat.to_sym
		return ChronicDuration.output(timeInSeconds, :format => outputFormat, :keep_zero => true)
	end


	def self.merge_issue_time_and_budget(issuesTime, issuesBudget)

		issuesTime.each do |t|

			issuesBudget.each do |b|

				if b["issue_number"] == t["issue_number"]
					t["budget_duration_sum"] = b["budget_duration_sum"]
					t["budget_comment_count"] = b["budget_comment_count"]
					break
				end					
			end
			if t.has_key?("budget_duration_sum") == false and t.has_key?("budget_comment_count") == false
				t["budget_duration_sum"] = nil
				t["budget_comment_count"] = nil
			end
		end

		return issuesTime
	end




	
end