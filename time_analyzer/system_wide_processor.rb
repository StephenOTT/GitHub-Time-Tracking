require_relative 'system_wide_aggregation'
require_relative 'helpers'


module System_Wide_Processor

	def self.all_repos_for_logged_user(githubAuthInfo)
		# userRepo = "#{user}/#{repo}"
		
		System_Wide_Aggregation.controller # makes mongo connection
		
		repos = System_Wide_Aggregation.get_all_repos_assigned_to_logged_user(githubAuthInfo)
		
		return repos
	end
end