# frozen_string_literal: true

require 'spec_helper'

describe Pariah::Dataset do
  before do
    store [
      {title: "Title 1", comments_count: 5},
      {title: "Title 2", comments_count: 9},
      {title: "Title 3", comments_count: 5},
    ]
  end

  after { clear_indices }

  describe "#each" do
    it "should iterate over the JSON documents matching the search" do
      titles = []
      FTS[:pariah_index_1].each do |doc|
        titles << doc[:title]
      end
      assert_equal ["Title 1", "Title 2", "Title 3"], titles.sort

      # Correct return result from #each?
      assert_equal ["Title 1", "Title 2", "Title 3"],
        FTS[:pariah_index_1].each{|d| d}.map{|h| h[:title]}.sort
    end

    it "should not load the results into the dataset on which it is called" do
      ds = FTS[:pariah_index_1].filter(term: {comments_count: 5})
      assert_nil ds.results

      titles = []
      ds.each { |doc| titles << doc[:title] }
      assert_equal ["Title 1", "Title 3"], titles.sort

      assert_nil ds.results
    end

    it "should allow for the use of Enumerable methods" do
      ds = FTS[:pariah_index_1]
      assert_nil ds.results
      assert_equal [5, 5, 9], ds.map{|doc| doc[:comments_count]}.sort
      assert_equal 19, ds.inject(0){|number, doc| number + doc[:comments_count]}
      assert_nil ds.results
    end
  end

  describe "#all" do
    it "should return an array of matching documents without mutating the dataset" do
      ds = FTS[:pariah_index_1].filter(term: {comments_count: 5})
      assert_nil ds.results

      all = ds.all
      assert_equal 2, all.length
      assert_equal ["Title 1", "Title 3"], all.map{|d| d[:title]}.sort

      assert_nil ds.results
    end
  end

  describe "#count" do
    it "should return a count of matching documents without mutating the dataset" do
      ds = FTS[:pariah_index_1].filter(term: {comments_count: 5})
      assert_nil ds.results
      assert_equal 2, ds.count
      assert_nil ds.results
    end
  end

  describe "#load" do
    it "should copy the dataset and load the results into it" do
      ds1 = FTS[:pariah_index_1].filter(term: {comments_count: 5})
      assert_nil ds1.results

      ds2 = ds1.load
      refute_nil ds2.results

      assert_equal 2, ds2.count
      assert_equal 2, ds2.all.length

      assert_nil ds1.results
    end
  end
end
