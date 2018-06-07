admin = User.create!(type: :Admin, username: 'admin', password: 'tomtom')

phaxio_manager = User.create!(type: :ClientManager, username: 'Phaxio Manager', password: 'mattmatt')
fake_manager = User.create!(type: :ClientManager, username: 'Fake Manager' , password: 'mattmatt')

phaxio = Client.create!(client_label: "Phaxio", client_manager_id: phaxio_manager.id, admin_id: admin.id)
fakers = Client.create!(client_label: "Fake Number Corporation", client_manager_id: fake_manager.id, admin_id: admin.id)

fake_num = FaxNumber.create!(fax_number_label: 'Fake Number 1', fax_number: '12025550141', client_id: fakers.id)
# FaxNumber.create!(fax_number_label: 'Fake Number 2', fax_number: '12025550163', client_id: fakers.id)
# FaxNumber.create!(fax_number_label: 'Fake Number 3', fax_number: '12025550126', client_id: fakers.id)
dev_num = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Modesto, California', client_id: phaxio.id)
founder_num = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Toll Free Number', client_id: phaxio.id)

phaxio_founders = Group.create!(group_label: "Phaxio Founders Group", client_id: phaxio.id, display_label: "Phaxio Founders", fax_number_id: founder_num.id)
fake_people = Group.create!(group_label: "Fake People", client_id: fakers.id, display_label: "lol", fax_number_id: fake_num.id)
phaxio_other = Group.create!(group_label: "Phaxio Devs", client_id: phaxio.id, fax_number_id: dev_num.id)


phaxio_user3 = Email.create!(email: 'ceo@phaxio.com', group_id: phaxio_founders.id, caller_id_number: 4)
phaxio_user4 = Email.create!(email: 'cto@phaxio.com', group_id: phaxio_founders.id, caller_id_number: 4)
phaxio_user1 = Email.create!(email: 'marketing1@phaxio.com', group_id: phaxio_other.id, caller_id_number: 5)
phaxio_user2 = Email.create!(email: 'marketing2@phaxio.com', group_id: phaxio_other.id, caller_id_number: 5)
phaxio_user5 = Email.create!(email: 'developer1@phaxio.com', group_id: phaxio_other.id, caller_id_number: 5)
phaxio_user6 = Email.create!(email: 'developer2@phaxio.com', group_id: phaxio_other.id, caller_id_number: 5)
phaxio_user7 = Email.create!(email: 'matt@phaxio.com', group_id: phaxio_other.id, caller_id_number: 5)

fake1 = Email.create!(email: 'faker1@aol.com', group_id: fake_people.id, caller_id_number: 1)#fake_people.fax_number.fax_number)
fake2 = Email.create!(email: 'faker2@aol.com', group_id: fake_people.id, caller_id_number: 2)#fake_people.fax_number.fax_number)
fake3 = Email.create!(email: 'faker3@aol.com', group_id: fake_people.id, caller_id_number: 3)#fake_people.fax_number.fax_number)
