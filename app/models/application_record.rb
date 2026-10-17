class ApplicationRecord < ActiveRecord::Base
  include Queryable

  primary_abstract_class
end
