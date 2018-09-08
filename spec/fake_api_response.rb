module FakeApiResponse

	def build_successful_sent_fax_objects(id, quantity, caller_id_number, recipient_number, organization_object, user_object, fake_data = [])
		quantity.times do
			obj = {'id' => id, 'direction' => 'sent', 'num_pages' => 1, 'status' => 'success', 'is_test' => false, 'created_at' => (DateTime.now + 7).to_s, 'cost' => 7, 'caller_id' => caller_id_number, 'tags' => { "sender_email_fax_tag" => user_object.fax_tag, "sender_organization_fax_tag" => organization_object.fax_tag }, 'recipients' => [{'phone_number' => recipient_number, 'status' => 'success', 'retry_count' => 0, 'completed_at' => (DateTime.now + 8).to_s, 'bitrate' => 9600, 'resolution' => 8040, 'error_type' => nil, 'error_id' => nil, 'error_message' => nil}], 'to_number' => nil, 'error_type' => nil, 'error_id' => nil, 'error_message' => nil}
			fake_data.push(obj)
			id += 1
		end
		fake_data
	end

	def build_failed_sent_fax_objects(id, quantity, caller_id_number, recipient_number, organization_object, user_object, fake_data = [])
		quantity.times do 
			obj = {'id' => id, 'direction' => 'sent', 'num_pages' => 1, 'status' => 'failure', 'is_test' => false, 'created_at' => (DateTime.now + 7), 'cost' => 0, 'caller_id' => caller_id_number, 'tags' => { "sender_email_fax_tag" => user_object.fax_tag, "sender_organization_fax_tag" => organization_object.fax_tag }, 'recipients' => [{'phone_number' => recipient_number, 'status' => 'failure', 'retry_count' => 0, 'completed_at' => (DateTime.now + 8), 'bitrate' => nil, 'resolution' => nil, 'error_type' => 'faxError', 'error_id' => 132, 'error_message' => "No fax tone detected"}], 'to_number' => nil, 'error_type' => nil, 'error_id' => nil, 'error_message' => nil}
			fake_data.push(obj)
			id += 1
		end
		fake_data
	end

	def build_successful_received_fax_objects(id, quantity, from_number, to_number, fake_data = [])
		quantity.times do
			obj = {'id' => id, 'direction' => 'received', 'num_pages' => 1, 'status' => 'success', 'is_test' => false, 'created_at' => (DateTime.now + 7), 'caller_id' => nil, 'from_number' => from_number, 'completed_at' => (DateTime.now + 8), 'cost' => 7, 'tags' => {}, "recipients"=> nil, "to_number"=>to_number, "error_id"=> nil, "error_type"=> nil, "error_message"=> nil }
			fake_data.push(obj)
			id += 1
		end
		fake_data
	end

	def build_failed_received_fax_objects(id, quantity, from_number, to_number, organization_object, user_object, fake_data = [])
		quantity.times do
			obj = {'id' => id, 'direction' => 'received', 'num_pages' => 0, 'status' => 'failure', 'is_test' => false, 'created_at' => (DateTime.now + 7), 'cost' => 0, 'caller_id' => nil, 'from_number' => from_number, 'completed_at' => (DateTime.now + 8), 'tags' => {}, "recipients"=>nil, "to_number"=>to_number, "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"}
			fake_data.push(obj)
			id += 1
		end
		fake_data
	end
end