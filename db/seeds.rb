admin = User.create!(type: :Admin, email: "mwmayerle@gmail.com", password: "mattmatt")

phaxio = Client.create!(client_label: "Phaxio Test Client", admin_id: admin.id)
fakers = Client.create!(client_label: "Fake Number Client", admin_id: admin.id)

phaxio_manager = User.create!(type: :ClientManager, email: "manager@phaxio.org", password: "mattmatt", client_id: phaxio.id)
fake_manager = User.create!(type: :ClientManager, email: "manager@fake.com", password: "mattmatt", client_id: fakers.id)

phaxio.update(client_manager_id: phaxio_manager.id)
fakers.update(client_manager_id: fake_manager.id)

UserEmail.create!(email_address: 'tom@tom.com', user_id: admin.id)
UserEmail.create!(email_address: 'manager@fake.com', user_id: fake_manager.id, client_id: fakers.id)
UserEmail.create!(email_address: 'manager@phaxio.org', user_id: phaxio_manager.id, client_id: phaxio.id)

dev_num = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Admin Made Label 1', client_id: phaxio.id, fax_number_display_label: "Phaxio Engineering")
founder_num = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Admin Made Label 2', client_id: phaxio.id,fax_number_display_label: "Phaxio Help Line")
fake_num1 = FaxNumber.create!(fax_number_label: 'Fake Number 1', fax_number: '12025550141', client_id: fakers.id, fax_number_display_label: "Fake Accounting")
fake_num2 = FaxNumber.create!(fax_number_label: 'Fake Number 3', fax_number: '12025550126', client_id: fakers.id, fax_number_display_label: "Fake Sales")

phaxio_user3 = UserEmail.create!(email_address: 'ceo@phaxio.org', caller_id_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user4 = UserEmail.create!(email_address: 'cto@phaxio.org', caller_id_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user1 = UserEmail.create!(email_address: 'marketing1@phaxio.org', caller_id_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user2 = UserEmail.create!(email_address: 'marketing2@phaxio.org', caller_id_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user5 = UserEmail.create!(email_address: 'developer1@phaxio.org', caller_id_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user6 = UserEmail.create!(email_address: 'developer2@phaxio.org', caller_id_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user7 = UserEmail.create!(email_address: 'matt@phaxio.org', caller_id_number: dev_num.fax_number, client_id: phaxio.id)

fake1 = UserEmail.create!(email_address: 'faker1@aol.com', caller_id_number: fake_num1.fax_number, client_id: fakers.id)
fake2 = UserEmail.create!(email_address: 'faker2@aol.com', caller_id_number: fake_num1.fax_number, client_id: fakers.id)
fake3 = UserEmail.create!(email_address: 'faker3@aol.com', caller_id_number: fake_num2.fax_number, client_id: fakers.id)

FaxNumberUserEmail.create!([
	{user_email_id: phaxio_user1.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user2.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user5.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user6.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user7.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user3.id, fax_number_id: dev_num.id},
	{user_email_id: phaxio_user3.id, fax_number_id: founder_num.id},
	{user_email_id: phaxio_user4.id, fax_number_id: founder_num.id},

	{user_email_id: fake1.id, fax_number_id: fake_num1.id},
	{user_email_id: fake2.id, fax_number_id: fake_num1.id},
	{user_email_id: fake3.id, fax_number_id: fake_num2.id},
])