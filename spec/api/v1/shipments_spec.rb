require 'byebug'
require 'faraday'
require 'json'

HTTP_SUCCESS = 200
HTTP_UNPROCESSABLE = 422
BASE_URL = 'http://localhost:3000' # Modify as needed

def reset_db
  system 'pg_restore --data-only glexport_development < glexport_development'
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
      it 'works' do
        response = http.get "#{BASE_URL}/api/v1/shipments"
        expect(response.status).to eq(HTTP_SUCCESS)
        json = JSON.parse(response.body)
        expect(json['records'][0]['name']).to eq('apparel from china')
      end
    end

    context 'with invalid params' do

    end
  end
end