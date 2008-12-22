require 'test_helper'

class ArticlesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "support article creation" do
    article = Article.create(
      :title => "What forms of payment do you take?", 
      :body => "We accept Visa, MC and AMEX.",
      :category => "support")
    assert_equals "What forms of payment do you take?", article.title
    assert_equals "We accept Visa, MC and AMEX.", article.body
    assert_equals "support", article.category
    
  end
end
