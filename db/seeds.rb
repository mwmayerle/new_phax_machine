admin = User.create!(type: :Admin, username: "admin", password: 'tomtom')
phaxio_manager = User.create!(type: :ClientManager, username: "phaxio_manager", password: 'mattmatt')

phaxio = Client.create!(client_label: "Phaxio Test Client", client_manager_id: phaxio_manager.id, admin_id: admin.id)

dev_num = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Admin Made Label 1', client_id: phaxio.id, fax_number_display_label: "Phaxio Engineering")
founder_num = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Admin Made Label 2', client_id: phaxio.id,fax_number_display_label: "Phaxio Help Line")

phaxio_user3 = Email.create!(email: 'ceo@phaxio.com', fax_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user4 = Email.create!(email: 'cto@phaxio.com', fax_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user1 = Email.create!(email: 'marketing1@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user2 = Email.create!(email: 'marketing2@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user5 = Email.create!(email: 'developer1@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user6 = Email.create!(email: 'developer2@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user7 = Email.create!(email: 'matt@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)

FaxNumberEmail.create!([
{email_id: phaxio_user1.id, fax_number_id: dev_num.id},
{email_id: phaxio_user2.id, fax_number_id: dev_num.id},
{email_id: phaxio_user5.id, fax_number_id: dev_num.id},
{email_id: phaxio_user6.id, fax_number_id: dev_num.id},
{email_id: phaxio_user7.id, fax_number_id: dev_num.id},
{email_id: phaxio_user3.id, fax_number_id: dev_num.id},
{email_id: phaxio_user3.id, fax_number_id: founder_num.id},
{email_id: phaxio_user4.id, fax_number_id: founder_num.id},
])
