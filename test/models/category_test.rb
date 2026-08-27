require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "transaction belongs to category" do
    association = Transaction.reflect_on_association(:category)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "category has many transactions" do
    association = Category.reflect_on_association(:transactions)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end
end
