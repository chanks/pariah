# frozen_string_literal: true

require 'pariah/dataset/mutations'
require 'pariah/dataset/actions'
require 'pariah/dataset/query'

module Pariah
  class Dataset
    include Enumerable
    include Mutations
    include Actions
    include Query

    attr_reader :opts, :results

    def initialize(url)
      @opts = {}
      @pool =
        Pond.new do
          Excon.new(
            url,
            persistent: true,
            headers: { 'Content-Type' => 'application/json' }
          )
        end

      # Ensure that the connection is good.
      synchronize do |conn|
        r = conn.get(path: '_cluster/health')
        raise "Bad Elasticsearch connection!" unless r.status == 200

        r =
          conn.put \
            path: '_template/template_all',
            body: JSON.dump(
              {
                template: '*',
                order: 0,
                settings: {
                  'index.mapper.dynamic' => false
                }
              }
            )

        raise "Bad Elasticsearch response!: #{r.body}" unless r.status == 200
      end
    end

    def synchronize(&block)
      @pool.checkout(&block)
    end
  end
end
