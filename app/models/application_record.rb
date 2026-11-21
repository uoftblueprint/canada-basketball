class ApplicationRecord < ActiveRecord::Base
  include Queryable
  include CsvExportable

  primary_abstract_class
end
