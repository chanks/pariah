require 'pariah/dataset/filters/and'
require 'pariah/dataset/filters/term'

module Pariah
  class Dataset
    module Mutations
      def [](*indices)
        merge_replace(indices: indices.flatten)
      end

      def append_indices(*indices)
        merge_append(indices: indices.flatten)
      end
      alias :append_index   :append_indices
      alias :append_indexes :append_indices

      def types(*types)
        merge_replace(types: types.flatten)
      end
      alias :type :types

      def append_types(*types)
        merge_append(types: types.flatten)
      end
      alias :append_type :append_types

      def term(condition = {})
        append_filters condition.map { |k, v| Filters::Term.new(k => v) }
      end

      def unfiltered
        merge_replace(filter: nil)
      end

      def sort(*args)
        merge_replace(sort: args.flatten)
      end

      def size(size)
        merge_replace(size: size)
      end

      def from(from)
        merge_replace(from: from)
      end

      protected

      def append_filters(filters)
        new_filter = case current_filter = @query[:filter]
                     when Filters::And then Filters::And.new(*current_filter.args, *filters)
                     when NilClass     then filters.length > 1 ? Filters::And.new(*filters) : filters.first
                     else                   Filters::And.new(current_filter, *filters)
                     end

        merge_replace filter: new_filter
      end

      def merge_replace(query)
        clone.tap { |clone| clone.merge_replace!(query) }
      end

      def merge_append(query)
        clone.tap { |clone| clone.merge_append!(query) }
      end

      def merge_replace!(query)
        @query = @query.merge(query)
      end

      def merge_append!(query)
        @query = @query.merge(query) do |key, oldval, newval|
          newval = [newval] unless newval.is_a?(Array)
          oldval + newval
        end
      end
    end
  end
end
