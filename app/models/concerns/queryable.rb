module Queryable
  extend ActiveSupport::Concern

  included do
    class_attribute :searchable_included_columns, default: []
    class_attribute :sortable_included_columns, default: []
  end

  class_methods do
    def searchable_by(*columns)
      self.searchable_included_columns = searchable_included_columns | columns.map(&:to_s)
    end

    def searchable_columns
      column_names & searchable_included_columns
    end

    def sortable_by(*columns)
      self.sortable_included_columns = sortable_included_columns | columns.map(&:to_s)
    end

    def sortable_columns
      column_names & sortable_included_columns
    end

    def search(query)
      return all if query.blank? || searchable_columns.empty?

      clause = searchable_columns
               .map { |c| "LOWER(#{text_cast(c)}) LIKE :q ESCAPE '\\'" }
               .join(" OR ")
      where(clause, q: "%#{sanitize_sql_like(query).downcase}%")
    end

    def ordered_by(column, direction)
      pk_column = arel_table[primary_key].asc
      # if there is no user sort active, keep the relation's order as the default
      # with a secondary sort on primary key
      return order(pk_column) unless sortable_columns.include?(column.to_s)

      dir = direction.to_s.casecmp?("desc") ? "desc" : "asc"
      # secondary sort on primary key
      reorder(arel_table[column].public_send(dir)).order(pk_column)
    end

    private

    def text_cast(column)
      type = case connection.adapter_name
             when /mysql/i then "CHAR"
             else "TEXT"
             end
      "CAST(#{connection.quote_column_name(column)} AS #{type})"
    end
  end
end
