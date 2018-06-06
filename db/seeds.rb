admin = User.create!(type: :Admin, email: 'tom@tom.com', password: 'tomtom')

phaxio_manager = User.create!(type: :ClientManager, email: 'phaxio_manager@phaxio.com', password: 'mattmatt')
fake_manager = User.create!(type: :ClientManager, email: 'faker1@aol.com', password: 'mattmatt')

phaxio = Client.create!(client_label: "Phaxio", client_manager_id: phaxio_manager.id, admin_id: admin.id )
fakers = Client.create!(client_label: "Fake Number Corporation", client_manager_id: fake_manager.id, admin_id: admin.id)
fakers.fax_numbers.create!([{ fax_number_label: 'Fake Number 1', fax_number: '12025550141' }, { fax_number_label: 'Fake Number 2', fax_number: '12025550163' }, { fax_number_label: 'Fake Number 3', fax_number: '12025550126' }])
phaxio.fax_numbers.create!([{ fax_number: '12096904545', fax_number_label: 'Modesto, California' }, { fax_number: '18777115706', fax_number_label: 'Toll Free Number' }])

phaxio_user3 = User.create!(type: :User, email: 'ceo@phaxio.com', password: 'mattmatt', client_id: phaxio.id)
phaxio_user4 = User.create!(type: :User, email: 'cto@phaxio.com', password: 'mattmatt', client_id: phaxio.id)
phaxio_user1 = User.create!(type: :User, email: 'marketing1@phaxio.com', password: 'mattmatt', client_id: phaxio.id)
phaxio_user2 = User.create!(type: :User, email: 'marketing2@phaxio.com', password: 'mattmatt', client_id: phaxio.id)
phaxio_user5 = User.create!(type: :User, email: 'developer1@phaxio.com', password: 'mattmatt', client_id: phaxio.id)
phaxio_user6 = User.create!(type: :User, email: 'developer2@phaxio.com', password: 'mattmatt', client_id: phaxio.id)

fake1 = User.create!(type: :User, email: 'faker2@aol.com', password: 'mattmatt', client_id: fakers.id)
fake2 = User.create!(type: :User, email: 'faker3@aol.com', password: 'mattmatt', client_id: fakers.id)
fake3 = User.create!(type: :User, email: 'faker3@aol.com', password: 'mattmatt', client_id: fakers.id)

phaxio_founders = Group.create!(group_label: "Phaxio Founders Group", client_id: phaxio.id)
phaxio_other = Group.create!(group_label: "Phaxio Employees", client_id: phaxio.id)
fake_people = Group.create!(group_label: "Fake People", client_id: fakers.id)

UserGroup.create!([
{user_id: phaxio_user4.id, group_id: phaxio_founders.id},
{user_id: phaxio_user3.id, group_id: phaxio_founders.id},
{user_id: phaxio_user1.id, group_id: phaxio.id},
{user_id: phaxio_user2.id, group_id: phaxio.id},
{user_id: phaxio_user5.id, group_id: phaxio.id},
{user_id: phaxio_user6.id, group_id: phaxio.id},
{user_id: fake1.id, group_id: fakers.id},
{user_id: fake2.id, group_id: fakers.id},
{user_id: fake3.id, group_id: fakers.id}
])