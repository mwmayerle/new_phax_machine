admin = User.create!(email: 'tom@tom.com', password: "tomtom", is_admin: true)

group_leader1 = User.create!(email: 'matt@phaxio.com', password: 'mattmatt', is_group_leader: true)
group_leader2 = User.create!(email: 'mwmayerle@gmail.com', password: 'mattmatt', is_group_leader: true)

user1 = User.create!(group_leader_id: group_leader1.id, email: 'matt+v1runscopeprod@phaxio.com', password: 'mattmatt')
user2 = User.create!(group_leader_id: group_leader1.id, email: 'matt+v2runscopeprod@phaxio.com', password: 'mattmatt')
user3 = User.create!(group_leader_id: group_leader2.id, email: 'accounting@email.com', password: 'mattmatt')
user4 = User.create!(group_leader_id: group_leader2.id, email: 'fakeaccountant@email.com', password: 'mattmatt')

group1 = Group.create!(group_leader_id: group_leader1.id, group_name: "Phaxio People", display_name: "Developers")
group2 = Group.create!(group_leader_id: group_leader2.id, group_name: "Phaxio Accounting Dept", display_name: "Accounting")

usergroup1 = UserGroup.create!(user_id: user1.id, group_id: group1.id)
usergroup2 = UserGroup.create!(user_id: user2.id, group_id: group1.id)
usergroup3 = UserGroup.create!(user_id: admin.id, group_id: group1.id)
usergroup4 = UserGroup.create!(user_id: admin.id, group_id: group2.id)
usergroup5 = UserGroup.create!(user_id: user3.id, group_id: group2.id)
usergroup6 = UserGroup.create!(user_id: user4.id, group_id: group2.id)

fax1 = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Modesto, California', admin_id: admin.id)
fax2 = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Toll Free Number', admin_id: admin.id)