require 'chronic_duration'

module Helpers

	def self.budget_left?(large, small)
		large - small
	end

	def self.convertSecondsToDurationFormat(timeInSeconds, outputFormat)
		outputFormat = outputFormat.to_sym
		return ChronicDuration.output(timeInSeconds, :format => outputFormat, :keep_zero => true)
	end
end