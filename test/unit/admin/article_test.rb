require 'test_helper'

class Admin::ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "support article creation" do
    article = Article.create(
      :title => "What is Interval?", 
      :body => "View, track, and share your powermeter data.",
      :category => "support")
    assert_equal "What is Interval?", article.title
    assert_equal "View, track, and share your powermeter data.", article.body
    assert_equal "what_is_interval", article.permalink
    assert_equal "support", article.category
    
  end
end
