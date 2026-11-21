module CsvExportable
  extend ActiveSupport::Concern

  included do
    class_attribute :csv_exportable_included_columns, default: []
  end

  class_methods do
    def csv_exportable(*columns)
      self.csv_exportable_included_columns = csv_exportable_included_columns | columns.map(&:to_s)
    end

    def exportable_columns
      column_names & csv_exportable_included_columns
    end

    def to_csv(records = all)
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << exportable_columns

        records.find_each { |r| csv << r.attributes.slice(*exportable_columns).values }
      end
    end
  end
end
