require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:southampton)
    stub_antivirus_api
    @product_one = products(:one)
    @product_one.source = sources(:product_one)
    @product_iphone = products(:iphone)
    @product_iphone.source = sources(:product_iphone)

    test_image1 = Rails.root.join("test/fixtures/files/testImage.png")
    test_image2 = Rails.root.join("test/fixtures/files/testImage2.png")
    @product_one.documents.attach(io: File.open(test_image1), filename: "testImage.png")
    @product_one.documents.attach(io: File.open(test_image2), filename: "testImage2.png")
  end

  test "should get index" do
    get products_path
    assert_response :success
  end

  test "should show product" do
    get product_path(@product_one)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_path(@product_one)
    assert_response :success
  end

  test "should update product" do
    patch product_path(@product_one),
          params: { product: {
            batch_number: @product_one.batch_number,
            product_type: @product_one.product_type,
            category: @product_one.category,
            description: @product_one.description,
            product_code: @product_one.product_code,
            webpage: @product_one.webpage,
            name: @product_one.name
          } }
    assert_redirected_to product_path(@product_one)
  end
end