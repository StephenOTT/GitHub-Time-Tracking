

module Accepted_Time_Tracking_Emoji

	def self.accepted_time_comment_emoji(*acceptedTimeCommentEmoji)
		acceptedTimeCommentEmoji = [":clock130:", ":clock11:", ":clock1230:", ":clock3:", ":clock430:", 
								":clock6:", ":clock730:", ":clock9:", ":clock10:", ":clock1130:", 
								":clock2:", ":clock330:", ":clock5:", ":clock630:", ":clock8:", 
								":clock930:", ":clock1:", ":clock1030:", ":clock12:", ":clock230:", 
								":clock4:", ":clock530:", ":clock7:", ":clock830:"]
	end

	def self.accepted_nonBillable_emoji(*acceptedNonBilliableEmoji)
		acceptedNonBilliableEmoji = [":free:"]
	end

end