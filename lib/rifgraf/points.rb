module Rifgraf
  module Points
    def self.data
      @@data ||= make
    end

    def self.make
      db = Sequel.connect(ENV["DATABASE_URL"] || "sqlite://rifgraf.db")
      make_table(db)
      db[:points]
    end

    def self.make_table(db)
      db.create_table :points do
        varchar :graph, :size => 32
        varchar :value, :size => 32
        timestamp :timestamp
      end
    rescue Sequel::DatabaseError
      # assume table already exists
    end
  end
end
