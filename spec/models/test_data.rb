[[
	{"id"=>82997561,
	 "direction"=>"sent",
	  "num_pages"=>1,
	   "status"=>"success",
	    "is_test"=>false,
	     "created_at"=>"2018-09-07T10:13:28.000-05:00",
	      "caller_id"=>"+12702166825",
	       "from_number"=>nil,
	        "completed_at"=>"2018-09-07T10:13:59.000-05:00",
	         "cost"=>7,
	          "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"62629e38-8e17-487a-b27d-f7d5a14d22c0"},
	           "recipients"=>[{"phone_number"=>"+12064081185", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-09-07T10:13:59.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}],
	            "to_number"=>nil,
	             "error_id"=>nil,
	              "error_type"=>nil,
	               "error_message"=>nil}],

[{
	"id"=>82997626,
	"direction"=>"received",
	"num_pages"=>1,
	"status"=>"success",
	"is_test"=>false,
	"created_at"=>"2018-09-07T10:14:11.000-05:00",
	"caller_id"=>nil,
	"from_number"=>"+12702166825",
	"completed_at"=>"2018-09-07T10:14:09.000-05:00",
	"cost"=>7,
	"tags"=>{},
	"recipients"=>nil,
	"to_number"=>"+12064081185",
	"error_id"=>nil,
	"error_type"=>nil,
	"error_message"=>nil
}], []]

test_data = [[
	{"id"=>81825292, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T16:57:10.000-05:00", "caller_id"=>"+19892601212", "from_number"=>nil, "completed_at"=>"2018-08-25T16:57:41.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"9072390b-b589-4c60-abe6-50cbc3fa8410", "sender_email_fax_tag"=>"2da15571-fbc1-478d-8b9e-7d1b5e0f60fe"}, "recipients"=>[{"phone_number"=>"+15312007291", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T16:57:40.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil},

	{"id"=>82467079, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-31T18:45:35.000-05:00", "caller_id"=>nil, "from_number"=>"+12316468160", "completed_at"=>"2018-08-31T18:45:35.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+18889814958", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>82410268, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-31T11:43:21.000-05:00", "caller_id"=>nil, "from_number"=>"+12035836353", "completed_at"=>"2018-08-31T11:43:21.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12035834392", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>82070619, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-28T14:06:10.000-05:00", "caller_id"=>nil, "from_number"=>"+17027070654", "completed_at"=>"2018-08-28T14:06:10.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12183894107", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>81956175, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-27T13:56:41.000-05:00", "caller_id"=>nil, "from_number"=>"+17027070654", "completed_at"=>"2018-08-27T13:56:41.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12183894107", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>81921305, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-27T08:48:42.000-05:00", "caller_id"=>nil, "from_number"=>"+12105492755", "completed_at"=>"2018-08-27T08:48:42.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12105472754", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>81825328, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T16:57:52.000-05:00", "caller_id"=>nil, "from_number"=>"+19892601212", "completed_at"=>"2018-08-25T16:57:50.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+15312007291", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil},


	{"id"=>81822281, "direction"=>"received", "num_pages"=>0, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-25T16:19:10.000-05:00", "caller_id"=>nil, "from_number"=>"+18015490437", "completed_at"=>"2018-08-25T16:19:10.000-05:00", "cost"=>0, "tags"=>{}, "recipients"=>nil, "to_number"=>"+18017690715", "error_id"=>132, "error_type"=>"faxError", "error_message"=>"No fax tone detected"},

	{"id"=>81807319, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:06:22.000-05:00", "caller_id"=>nil, "from_number"=>"+12064081185", "completed_at"=>"2018-08-25T12:06:19.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12064081185", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil},

	{"
		id"=>81807307, 
		"direction"=>"received", 
		"num_pages"=>1, 
		"status"=>"success", 
		"is_test"=>false, 
		"created_at"=>"2018-08-25T12:06:10.000-05:00", 
		"caller_id"=>nil, 
		"from_number"=>"+12064081185", 
		"completed_at"=>"2018-08-25T12:06:08.000-05:00", 
		"cost"=>7, 
		"tags"=>{}, 
		"recipients"=>nil, 
		"to_number"=>"+12702166825", 
		"error_id"=>nil, 
		"error_type"=>nil, 
		"error_message"=>nil
	},

		{"id"=>81807270, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:05:40.000-05:00", "caller_id"=>"+12064081185", "from_number"=>nil, "completed_at"=>"2018-08-25T12:06:10.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"909f4376-8236-46ab-a1c7-ed7cfde9ac73"}, "recipients"=>[{"phone_number"=>"+12064081185", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:06:10.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807258, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:05:27.000-05:00", "caller_id"=>"+12064081185", "from_number"=>nil, "completed_at"=>"2018-08-25T12:05:58.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"909f4376-8236-46ab-a1c7-ed7cfde9ac73"}, "recipients"=>[{"phone_number"=>"+12702166825", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:05:58.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807253, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:05:19.000-05:00", "caller_id"=>nil, "from_number"=>"+12702166825", "completed_at"=>"2018-08-25T12:05:17.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12064081185", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, 

	{"id"=>81807216, "direction"=>"sent", "num_pages"=>1, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-25T12:04:50.000-05:00", "caller_id"=>"+12702166825", "from_number"=>nil, "completed_at"=>"2018-08-25T12:05:44.000-05:00", "cost"=>0, "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"62629e38-8e17-487a-b27d-f7d5a14d22c0"}, "recipients"=>[{"phone_number"=>"+12242136849", "status"=>"failure", "retry_count"=>0, "completed_at"=>"2018-08-25T12:05:43.000-05:00", "bitrate"=>nil, "resolution"=>nil, "error_type"=>"faxError", "error_id"=>132, "error_message"=>"No fax tone detected"}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil},

	 {"id"=>81807215, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:04:48.000-05:00", "caller_id"=>nil, "from_number"=>"+12702166825", "completed_at"=>"2018-08-25T12:04:46.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12702166825", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807204, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:04:37.000-05:00", "caller_id"=>"+12702166825", "from_number"=>nil, "completed_at"=>"2018-08-25T12:05:08.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"62629e38-8e17-487a-b27d-f7d5a14d22c0"}, "recipients"=>[{"phone_number"=>"+12064081185", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:05:08.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807186, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:04:07.000-05:00", "caller_id"=>"+12702166825", "from_number"=>nil, "completed_at"=>"2018-08-25T12:04:37.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"56f3acf6-26d3-436e-8392-97072e87a8cd", "sender_email_fax_tag"=>"62629e38-8e17-487a-b27d-f7d5a14d22c0"}, "recipients"=>[{"phone_number"=>"+12702166825", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:04:37.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807157, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:03:32.000-05:00", "caller_id"=>nil, "from_number"=>"+12183894107", "completed_at"=>"2018-08-25T12:03:29.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12183894107", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807149, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:03:17.000-05:00", "caller_id"=>nil, "from_number"=>"+12183894107", "completed_at"=>"2018-08-25T12:03:15.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+18889814958", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807111, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:02:43.000-05:00", "caller_id"=>nil, "from_number"=>"+18889814958", "completed_at"=>"2018-08-25T12:02:41.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+12183894107", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807108, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:02:42.000-05:00", "caller_id"=>"+12183894107", "from_number"=>nil, "completed_at"=>"2018-08-25T12:03:20.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"4c96ecf1-9d46-4b5c-a23d-cbc7a6d40d05", "sender_email_fax_tag"=>"8f5cb02a-ae69-4059-bdb4-5764e6762b9b"}, "recipients"=>[{"phone_number"=>"+12183894107", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:03:20.000-05:00", "bitrate"=>7200, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807100, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:02:34.000-05:00", "caller_id"=>"+12183894107", "from_number"=>nil, "completed_at"=>"2018-08-25T12:03:06.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"4c96ecf1-9d46-4b5c-a23d-cbc7a6d40d05", "sender_email_fax_tag"=>"8f5cb02a-ae69-4059-bdb4-5764e6762b9b"}, "recipients"=>[{"phone_number"=>"+18889814958", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:03:06.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807094, "direction"=>"received", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:02:24.000-05:00", "caller_id"=>nil, "from_number"=>"+18889814958", "completed_at"=>"2018-08-25T12:02:22.000-05:00", "cost"=>7, "tags"=>{}, "recipients"=>nil, "to_number"=>"+18889814958", "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807092, "direction"=>"sent", "num_pages"=>1, "status"=>"failure", "is_test"=>false, "created_at"=>"2018-08-25T12:02:14.000-05:00", "caller_id"=>"+18889814958", "from_number"=>nil, "completed_at"=>"2018-08-25T12:03:06.000-05:00", "cost"=>0, "tags"=>{"sender_organization_fax_tag"=>"4c96ecf1-9d46-4b5c-a23d-cbc7a6d40d05", "sender_email_fax_tag"=>"97487855-ee67-4290-8136-8c3fd3418d81"}, "recipients"=>[{"phone_number"=>"+12242136849", "status"=>"failure", "retry_count"=>0, "completed_at"=>"2018-08-25T12:03:06.000-05:00", "bitrate"=>nil, "resolution"=>nil, "error_type"=>"faxError", "error_id"=>132, "error_message"=>"No fax tone detected"}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}, {"id"=>81807074, "direction"=>"sent", "num_pages"=>1, "status"=>"success", "is_test"=>false, "created_at"=>"2018-08-25T12:02:02.000-05:00", "caller_id"=>"+18889814958", "from_number"=>nil, "completed_at"=>"2018-08-25T12:02:31.000-05:00", "cost"=>7, "tags"=>{"sender_organization_fax_tag"=>"4c96ecf1-9d46-4b5c-a23d-cbc7a6d40d05", "sender_email_fax_tag"=>"97487855-ee67-4290-8136-8c3fd3418d81"}, "recipients"=>[{"phone_number"=>"+12183894107", "status"=>"success", "retry_count"=>0, "completed_at"=>"2018-08-25T12:02:31.000-05:00", "bitrate"=>9600, "resolution"=>8040, "error_type"=>nil, "error_id"=>nil, "error_message"=>nil}], "to_number"=>nil, "error_id"=>nil, "error_type"=>nil, "error_message"=>nil}]]