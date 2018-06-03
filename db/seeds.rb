
admin = User.create!(email: 'tom@tom.com', password: "tomtom", is_admin: true)

super_user1 = SuperUser.create!(super_user_email: 'matt@phaxio.com', password: 'mattmatt')
super_user2 = SuperUser.create!(super_user_email: 'mwmayerle@gmail.com', password: 'mattmatt')

user1 = User.create!(super_user_id: super_user1.id, email: 'matt+v1runscopeprod@phaxio.com', password: 'mattmatt')
user2 = User.create!(super_user_id: super_user1.id, email: 'matt+v2runscopeprod@phaxio.com', password: 'mattmatt')
user3 = User.create!(super_user_id: super_user2.id, email: 'accounting@email.com', password: 'mattmatt')
user4 = User.create!(super_user_id: super_user2.id, email: 'fakeaccountant@email.com', password: 'mattmatt')
user5 = User.create!(super_user_id: super_user1.id, email: 'mwmayerle@gmail.com', password: 'mattmatt')

group1 = Group.create!(super_user_id: user1.id, group_name: "Phaxio People", display_name: "Developers")
group2 = Group.create!(super_user_id: user3.id, group_name: "Phaxio Accounting Dept", display_name: "Accounting")

usergroup1 = UserGroup.create!(user_id: user1.id, group_id: group1.id)
usergroup2 = UserGroup.create!(user_id: user2.id, group_id: group1.id)
usergroup3 = UserGroup.create!(user_id: admin.id, group_id: group1.id)
usergroup4 = UserGroup.create!(user_id: admin.id, group_id: group2.id)
usergroup5 = UserGroup.create!(user_id: user3.id, group_id: group2.id)
usergroup6 = UserGroup.create!(user_id: user4.id, group_id: group2.id)
usergroup7 = UserGroup.create!(user_id: user5.id, group_id: group2.id)
usergroup8 = UserGroup.create!(user_id: user5.id, group_id: group1.id)


fax1 = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Modesto, California')
fax2 = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Toll Free Number')