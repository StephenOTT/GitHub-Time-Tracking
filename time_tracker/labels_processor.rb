require_relative 'accepted_labels_categories'

module Labels_Processor

		# parse through GitHub labels and return label names in an array
	def self.get_label_names(labelsData)
		issueLabels = []
		if labelsData != nil
			labelsData.each do |x|
				issueLabels << x["name"]
			end
		end
		return issueLabels
	end

	def self.process_issue_labels(ghLabels, options = {})
		output = []
		
		if options[:acceptedLabels] == nil
			# Exaple/Default labels.
			acceptedLabels = Accepted_Labels_Categories.accepted_labels_categories
		end

		if ghLabels != nil
			ghLabels.each do |x|
				# clears the outputHash variable every time a new Label is inspected
				outputHash = {}

				# does a check to see if the label is one of the Accepted Labels.
				anyAcceptedLabelsTF = acceptedLabels.any? { |b| [b[:category],b[:label]].join(" ") == x }
				
				# If the label is a accepted label then process
				if anyAcceptedLabelsTF == true
					acceptedLabels.each do |y|
						if [y[:category], y[:label]].join(" ") == x
							# Add the Category to the Cateogry field and Removes the colon character from category name
							outputHash["category"] = y[:category][0..-2]
							
							outputHash["label"] = y[:label]
							output << outputHash
						end
					end

				# If the label is not an accepted label then make the category field nil
				elsif anyAcceptedLabelsTF == false
					outputHash["category"] = nil
					outputHash["label"] = x
					output << outputHash
				end
			end
		else
			output = []
		end
		return output
	end
end