

BELOW IS @sorted_faxes for 5 fake organizations. Each organization has two fax numbers.
Each organization has a manager (org_###_manager@aol) and a user (org_###_user@aol).
Each user has one of the two fax numbers as their caller_id_number.
The manager sends 3 faxes, 1 to each fax number in the organization, and 1 to a number that creates a failure.
So 5 faxes per organization, 4 are successful, 1 is not.

# ORGANIZATION 5
{81807319=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_five_user@aol.com", "organization"=>"Org Five", "to_number"=>"(206) 408-1185", "from_number"=>"(206) 408-1185", "created_at"=>"12:06:22pm - 08/25/18"},
81807307=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_five_user@aol.com", "organization"=>"Org Five", "to_number"=>"(270) 216-6825", "from_number"=>"(206) 408-1185", "created_at"=>"12:06:10pm - 08/25/18"},
81807270=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Five", "from_number"=>"(206) 408-1185", "to_number"=>"(206) 408-1185", "sent_by"=>"org_five_user@aol.com", "created_at"=>"12:05:40pm - 08/25/18"},
81807258=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Five", "from_number"=>"(206) 408-1185", "to_number"=>"(270) 216-6825", "sent_by"=>"org_five_user@aol.com", "created_at"=>"12:05:27pm - 08/25/18"},
81807253=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_five_manager@aol.com", "organization"=>"Org Five", "to_number"=>"(206) 408-1185", "from_number"=>"(270) 216-6825", "created_at"=>"12:05:19pm - 08/25/18"},
81807216=>{"status"=>"Failure", "direction"=>"Sent", "organization"=>"Org Five", "from_number"=>"(270) 216-6825", "to_number"=>"(224) 213-6849", "sent_by"=>"org_five_manager@aol.com", "created_at"=>"12:04:50pm - 08/25/18"},
81807215=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_five_manager@aol.com", "organization"=>"Org Five", "to_number"=>"(270) 216-6825", "from_number"=>"(270) 216-6825", "created_at"=>"12:04:48pm - 08/25/18"},
81807204=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Five", "from_number"=>"(270) 216-6825", "to_number"=>"(206) 408-1185", "sent_by"=>"org_five_manager@aol.com", "created_at"=>"12:04:37pm - 08/25/18"},
81807186=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Five", "from_number"=>"(270) 216-6825", "to_number"=>"(270) 216-6825", "sent_by"=>"org_five_manager@aol.com", "created_at"=>"12:04:07pm - 08/25/18"},

# ORGANIZATION 4
81807157=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_four_user@aol.com", "organization"=>"Org Four", "to_number"=>"(218) 389-4107", "from_number"=>"(218) 389-4107", "created_at"=>"12:03:32pm - 08/25/18"},
81807149=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_four_user@aol.com", "organization"=>"Org Four", "to_number"=>"(888) 981-4958", "from_number"=>"(218) 389-4107", "created_at"=>"12:03:17pm - 08/25/18"},
81807111=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_four_manager@aol.com", "organization"=>"Org Four", "to_number"=>"(218) 389-4107", "from_number"=>"(888) 981-4958", "created_at"=>"12:02:43pm - 08/25/18"},
81807108=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Four", "from_number"=>"(218) 389-4107", "to_number"=>"(218) 389-4107", "sent_by"=>"org_four_user@aol.com", "created_at"=>"12:02:42pm - 08/25/18"},
81807100=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Four", "from_number"=>"(218) 389-4107", "to_number"=>"(888) 981-4958", "sent_by"=>"org_four_user@aol.com", "created_at"=>"12:02:34pm - 08/25/18"},
81807094=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_four_manager@aol.com", "organization"=>"Org Four", "to_number"=>"(888) 981-4958", "from_number"=>"(888) 981-4958", "created_at"=>"12:02:24pm - 08/25/18"},
81807092=>{"status"=>"Failure", "direction"=>"Sent", "organization"=>"Org Four", "from_number"=>"(888) 981-4958", "to_number"=>"(224) 213-6849", "sent_by"=>"org_four_manager@aol.com", "created_at"=>"12:02:14pm - 08/25/18"},
81807074=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Four", "from_number"=>"(888) 981-4958", "to_number"=>"(218) 389-4107", "sent_by"=>"org_four_manager@aol.com", "created_at"=>"12:02:02pm - 08/25/18"},
81807050=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Four", "from_number"=>"(888) 981-4958", "to_number"=>"(888) 981-4958", "sent_by"=>"org_four_manager@aol.com", "created_at"=>"12:01:39pm - 08/25/18"},

# ORGANIZATION 3
81806864=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_three_user@aol.com", "organization"=>"Org Three", "to_number"=>"(660) 951-7837", "from_number"=>"(971) 238-1875", "created_at"=>"11:58:06am - 08/25/18"},
81806843=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_three_user@aol.com", "organization"=>"Org Three", "to_number"=>"(971) 238-1875", "from_number"=>"(971) 238-1875", "created_at"=>"11:57:58am - 08/25/18"},
81806829=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Three", "from_number"=>"(971) 238-1875", "to_number"=>"(660) 951-7837", "sent_by"=>"org_three_user@aol.com", "created_at"=>"11:57:24am - 08/25/18"},
81806821=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Three", "from_number"=>"(971) 238-1875", "to_number"=>"(971) 238-1875", "sent_by"=>"org_three_user@aol.com", "created_at"=>"11:57:15am - 08/25/18"},
81806784=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_three_manager@aol.com", "organization"=>"Org Three", "to_number"=>"(971) 238-1875", "from_number"=>"(660) 951-7837", "created_at"=>"11:56:45am - 08/25/18"},
81806768=>{"status"=>"Failure", "direction"=>"Sent", "organization"=>"Org Three", "from_number"=>"(660) 951-7837", "to_number"=>"(224) 213-6849", "sent_by"=>"org_three_manager@aol.com", "created_at"=>"11:56:30am - 08/25/18"},
81806763=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_three_manager@aol.com", "organization"=>"Org Three", "to_number"=>"(660) 951-7837", "from_number"=>"(660) 951-7837", "created_at"=>"11:56:21am - 08/25/18"},
81806747=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Three", "from_number"=>"(660) 951-7837", "to_number"=>"(971) 238-1875", "sent_by"=>"org_three_manager@aol.com", "created_at"=>"11:56:03am - 08/25/18"},
81806724=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Three", "from_number"=>"(660) 951-7837", "to_number"=>"(660) 951-7837", "sent_by"=>"org_three_manager@aol.com", "created_at"=>"11:55:39am - 08/25/18"},

# ORGANIZATION 2
81749294=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_two_user@aol.com", "organization"=>"Org Two", "to_number"=>"(928) 504-0153", "from_number"=>"(928) 504-0153", "created_at"=>"03:39:45pm - 08/24/18"},
81749280=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_two_user@aol.com", "organization"=>"Org Two", "to_number"=>"(531) 200-7291", "from_number"=>"(928) 504-0153", "created_at"=>"03:39:34pm - 08/24/18"},
81749215=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Two", "from_number"=>"(928) 504-0153", "to_number"=>"(928) 504-0153", "sent_by"=>"org_two_user@aol.com", "created_at"=>"03:39:02pm - 08/24/18"},
81749196=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Two", "from_number"=>"(928) 504-0153", "to_number"=>"(531) 200-7291", "sent_by"=>"org_two_user@aol.com", "created_at"=>"03:38:53pm - 08/24/18"},
81749173=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_two_manager@aol.com", "organization"=>"Org Two", "to_number"=>"(531) 200-7291", "from_number"=>"(531) 200-7291", "created_at"=>"03:38:39pm - 08/24/18"},
81749154=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_two_manager@aol.com", "organization"=>"Org Two", "to_number"=>"(928) 504-0153", "from_number"=>"(531) 200-7291", "created_at"=>"03:38:28pm - 08/24/18"},
81749125=>{"status"=>"Failure", "direction"=>"Sent", "organization"=>"Org Two", "from_number"=>"(531) 200-7291", "to_number"=>"(224) 213-6849", "sent_by"=>"org_two_manager@aol.com", "created_at"=>"03:38:11pm - 08/24/18"},
81749078=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Two", "from_number"=>"(531) 200-7291", "to_number"=>"(531) 200-7291", "sent_by"=>"org_two_manager@aol.com", "created_at"=>"03:37:57pm - 08/24/18"},
81749014=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org Two", "from_number"=>"(531) 200-7291", "to_number"=>"(928) 504-0153", "sent_by"=>"org_two_manager@aol.com", "created_at"=>"03:37:26pm - 08/24/18"},

# ORGANIZATION 1
81748363=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_one_user@aol.com", "organization"=>"Org One", "to_number"=>"(801) 769-0715", "from_number"=>"(801) 769-0715", "created_at"=>"03:31:37pm - 08/24/18"},
81748327=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_one_user@aol.com", "organization"=>"Org One", "to_number"=>"(989) 260-1212", "from_number"=>"(801) 769-0715", "created_at"=>"03:31:15pm - 08/24/18"},
81748276=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org One", "from_number"=>"(801) 769-0715", "to_number"=>"(801) 769-0715", "sent_by"=>"org_one_user@aol.com", "created_at"=>"03:30:55pm - 08/24/18"},
81748249=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org One", "from_number"=>"(801) 769-0715", "to_number"=>"(989) 260-1212", "sent_by"=>"org_one_user@aol.com", "created_at"=>"03:30:33pm - 08/24/18"},
81748055=>{"status"=>"Failure", "direction"=>"Sent", "organization"=>"Org One", "from_number"=>"(989) 260-1212", "to_number"=>"(224) 213-6849", "sent_by"=>"org_one_manager@aol.com", "created_at"=>"03:29:04pm - 08/24/18"},
81747904=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_one_manager@aol.com", "organization"=>"Org One", "to_number"=>"(989) 260-1212", "from_number"=>"(989) 260-1212", "created_at"=>"03:27:52pm - 08/24/18"},
81747864=>{"status"=>"Success", "direction"=>"Received", "sent_by"=>"org_one_manager@aol.com", "organization"=>"Org One", "to_number"=>"(801) 769-0715", "from_number"=>"(989) 260-1212", "created_at"=>"03:27:23pm - 08/24/18"},
81747841=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org One", "from_number"=>"(989) 260-1212", "to_number"=>"(989) 260-1212", "sent_by"=>"org_one_manager@aol.com", "created_at"=>"03:27:09pm - 08/24/18"},
81747786=>{"status"=>"Success", "direction"=>"Sent", "organization"=>"Org One", "from_number"=>"(989) 260-1212", "to_number"=>"(801) 769-0715", "sent_by"=>"org_one_manager@aol.com", "created_at"=>"03:26:41pm - 08/24/18"},