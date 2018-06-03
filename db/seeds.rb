# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = Admin.create!(admin_email: 'tom@tom.com', password: "tomtom")

superuser1 = SuperUser.create!(admin_id: admin.id, super_user_email: 'matt@phaxio.com', password: 'mattmatt',)

user1 = User.create!(super_user_id: superuser1.id, user_email: 'matt+v1runscopeprod@phaxio.com', password: 'mattmatt')
user2 = User.create!(super_user_id: superuser1.id, user_email: 'matt+v2runscopeprod@phaxio.com', password: 'mattmatt')

fax1 = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Modesto, California')
fax2 = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Toll Free Number')