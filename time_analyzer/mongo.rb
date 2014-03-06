require 'mongo'

module Mongo_Connection

include Mongo

	def self.clear_mongo_collections
		@collTimeTrackingCommits.remove
	end


	def self.putIntoMongoCollTimeTrackingCommits(mongoPayload)
		@collTimeTrackingCommits.insert(mongoPayload)
	end


	def self.mongo_Connect(url, port, dbName, collName)
		# MongoDB Database Connect
		@client = MongoClient.new(url, port)
		# @client = MongoClient.new("localhost", 27017)

		# code for working with MongoLab
		# uri = "mongodb://USERNAME:PASSWORD@ds061268.mongolab.com:61268/TimeTrackingCommits"
		# @client = MongoClient.from_uri(uri)

		@db = @client[dbName]

		@collTimeTrackingCommits = @db[collName]

	end

	def self.aggregate_test(input1)
		
		@collTimeTrackingCommits.aggregate(input1)

	end

end