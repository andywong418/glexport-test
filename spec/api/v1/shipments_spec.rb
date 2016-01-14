require 'byebug'
require 'faraday'
require 'json'
require 'config'

def reset_db
  puts RESET_DB_COMMAND
  system RESET_DB_COMMAND
end

def http
  connection = Faraday.new
  connection.headers['Content-Type'] = 'application/json'
  connection.headers['Accept'] = 'application/json'
  return connection
end

RSpec.describe "api/v1/shipments resouces" do
  context "GET index" do
    before(:all) { reset_db }

    context 'with valid params' do
      context 'json content' do
        # Tests the structure of the returned json
        # What should be returned when hitting /api/v1/shipments?company_id=#{YALMART_ID}
        # {
        #   "records": [
        #     {
        #       "id": 1,
        #       "name": "yalmart apparel from china",
        #       "products": [
        #         {
        #           "quantity": 123,
        #           "id": 1,
        #           "sku": "shoe1",
        #           "description": "shoes",
        #           "active_shipment_count": 1
        #         },
        #         {
        #           "quantity": 234,
        #           "id": 2,
        #           "sku": "pant1",
        #           "description": "pants",
        #           "active_shipment_count": 2
        #         }
        #       ]
        #     },
        #     {
        #       "id": 2,
        #       ...
        #     },
        #     {
        #       "id": 3,
        #       ...
        #     }
        #   ]
        # }

        context 'shipment json' do
          it 'includes shipment name' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            # Uncomment below to output the response json in your shell
            # puts JSON.pretty_generate(json)
            expect(json['records'].map { |shipment_json| shipment_json['name'] }).to include('yalmart apparel from china')
          end
        end

        context 'products json' do
          it 'includes product info and shipment specific product information' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            yalmart_apparel_from_china_shipment_json = json['records'].find { |shipment_json| shipment_json['name'] == 'yalmart apparel from china'}
            products_json = yalmart_apparel_from_china_shipment_json['products']
            expect(products_json.map { |product_json| product_json['id'].to_i }).to match_array([1, 2]) # match_array matches true for both [1,2] and [2,1]
            expect(products_json.map { |product_json| product_json['sku'] }).to match_array(['shoe1', 'pant1'])
            expect(products_json.map { |product_json| product_json['description'] }).to match_array(['shoes', 'pants'])
            expect(products_json.map { |product_json| product_json['quantity'].to_i }).to match_array([123, 234])
          end

          it 'includes the calculated attribute active_shipment_count' do
            # This active_shipment_count field should be a code smell to you
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            yalmart_apparel_from_china_shipment_json = json['records'].find { |shipment_json| shipment_json['name'] == 'yalmart apparel from china'}
            products_json = yalmart_apparel_from_china_shipment_json['products']
            expect(products_json.map { |product_json| product_json['active_shipment_count'].to_i }).to match_array([1, 2])
          end
        end
      end

      context 'sorts' do
        # Company YALMART has three shipments, departing (in order of id) Jan 1, Jan 3, Jan 2

        context 'default sort' do
          it 'sorts by id ascending by default' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([1,2,3])
          end
        end

        context 'international departure date' do
          it 'allows ascending sort' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}&sort=international_departure_date&direction=asc"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([1,3,2])
          end

          it 'allows descending sort' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}&sort=international_departure_date&direction=desc"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([2,3,1])
          end
        end
      end

      context 'filters' do
        # Company YALMART has three shipments, two by ocean and one by truck

        context 'international_transportation_mode' do
          it 'filters by ocean' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}&international_transportation_mode=ocean"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to match_array([1, 2])
          end

          it 'filters by truck' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{YALMART_ID}&international_transportation_mode=truck"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to match_array([3])
          end
        end
      end

      context 'pagination' do
        # Company DOSTCO has six shipments, with ids [4, 5, 6, 7, 8, 9]

        context 'with no params' do
          it 'defaults to 4 results' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{DOSTCO_ID}"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([4, 5, 6, 7])
          end
        end

        context 'with page params' do
          it 'allows page navigation with the default 4 per page' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{DOSTCO_ID}&page=2"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([8, 9])
          end
        end

        context 'with explicit page and per params' do
          it 'allows custom pagination' do
            response = http.get "#{BASE_URL}/api/v1/shipments?company_id=#{DOSTCO_ID}&page=2&per=2"
            expect(response.status).to eq(HTTP_SUCCESS)
            json = JSON.parse(response.body)
            expect(json['records'].map { |shipment_json| shipment_json['id'] }).to eq([6, 7])
          end
        end
      end
    end

    context 'with invalid params' do
      context 'company_id is not provided' do
        it 'returns an errored response and a useful error message' do
          response = http.get "#{BASE_URL}/api/v1/shipments"
          expect(response.status).to eq(HTTP_UNPROCESSABLE)
          json = JSON.parse(response.body)
          expect(json['errors']).to eq(['company_id is required'])
        end
      end
    end
  end
end