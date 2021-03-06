# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  after { clear_indices }

  describe "#filter" do
    it "should add a filter to the search" do
      store [
        {title: "Title 1", comments_count: 5},
        {title: "Title 2", comments_count: 9},
      ]

      assert_equal ["Title 1"], FTS.filter(term: {comments_count: 5}).map{|doc| doc[:title]}
    end
  end
end
