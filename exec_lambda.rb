require 'dotenv'
require 'aws-sdk'

Dotenv.load

lambda = Aws::Lambda::Client.new(
  region: ENV['REGION'],
		access_key_id: ENV['AWS_ACCESS_KEY_ID'],
		secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
)

begin
		param = { "key1": "Hello Ruby!!" }.to_json

		resp = lambda.invoke({
				function_name: "hello-world",
				invocation_type: "Event",
				log_type: "None",
				client_context: "String",
				payload: param
		})

		if resp.status_code == 202
				p "接続できましたよ"
		end
rescue Aws::Lambda::Errors::ServiceError => e
		p e.message
end