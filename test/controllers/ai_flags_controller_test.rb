require "test_helper"

class AiFlagsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ai_flags_url
    assert_response :success
  end

  test "renders the flag log" do
    get ai_flags_url

    assert_match "AI Flag Transparency Log", response.body
    assert_match "Midterm predictions thread", response.body
  end
end
