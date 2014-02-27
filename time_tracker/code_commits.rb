require_relative 'helpers'	
require_relative 'code_commit_messages'
require_relative 'code_commit_comments'

module GH_Commits

	def self.process_code_commit(repo, commitDetails, commitComments)
		
		commitMessage = commitDetails.attrs[:commit].attrs[:message]

		type = "Code Commit"
		recordCreationDate = Time.now.utc
		
		commitAuthorUsername 	= commitDetails.attrs[:author].attrs[:login]
		commitAuthorDate 		= commitDetails.attrs[:commit].attrs[:author].attrs[:date]
		commitCommitterUsername = commitDetails.attrs[:committer].attrs[:login]
		commitCommitterDate 	= commitDetails.attrs[:commit].attrs[:committer].attrs[:date]
		commitSha 				= commitDetails.attrs[:sha]
		commitTreeSha 			= commitDetails.attrs[:commit].attrs[:tree].attrs[:sha]
		commitParentsShas 		= []
		
		# TODO look to crate this if statement as a helper if it makes sense
		if commitDetails.attrs[:parents] != nil
			commitDetails.attrs[:parents].each do |x|
				commitParentsShas << x.attrs[:sha]
			end
		end

		parsedCommitMessage = Commit_Messages.process_commit_message_for_time(commitMessage)
		parsedCommitComments = []

		# commitComments = Helpers.get_commit_comments(repo, commitSha)

		commitComments.each do |x|
			parsedCommitComment = Commit_Comments.process_commit_comment_for_time(x)
			if parsedCommitComment.empty? == false
				parsedCommitComments << parsedCommitComment
			end
		end
		

		if parsedCommitMessage.empty? == true and parsedCommitComments.empty? == true
			return []
		else
			timeCommitHash = {	"type" => type,
								"repo_name" => repo,
								"commit_author_username" => commitAuthorUsername,
								"commit_author_date" => commitAuthorDate,
								"commit_committer_username" => commitCommitterUsername,
								"commit_committer_date" => commitCommitterDate,
								"commit_sha" => commitSha,
								"commit_tree_sha" => commitTreeSha,
								"commit_parents_shas" => commitParentsShas,
								"record_creation_date" => recordCreationDate,
								"commit_message_time" => parsedCommitMessage,
								"commit_comments_time" => parsedCommitComments,
							}
		end
	end
end