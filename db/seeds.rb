admin = User.create!(type: :Admin, username: "admin", password: 'tomtom')
phaxio_manager = User.create!(type: :ClientManager, username: "phaxio_manager", password: 'mattmatt')
fake_manager = User.create!(type: :ClientManager, username: "fake_manager" , password: 'mattmatt')

phaxio = Client.create!(client_label: "Phaxio Test Client", client_manager_id: phaxio_manager.id, admin_id: admin.id)
fakers = Client.create!(client_label: "Fake Number Client", client_manager_id: fake_manager.id, admin_id: admin.id)

dev_num = FaxNumber.create!(fax_number: '12096904545', fax_number_label: 'Admin Made Label 1', client_id: phaxio.id, fax_number_display_label: "Phaxio Engineering")
founder_num = FaxNumber.create!(fax_number: '18777115706', fax_number_label: 'Admin Made Label 2', client_id: phaxio.id,fax_number_display_label: "Phaxio Help Line")
fake_num1 = FaxNumber.create!(fax_number_label: 'Fake Number 1', fax_number: '12025550141', client_id: fakers.id, fax_number_display_label: "Fake Accounting")
fake_num2 = FaxNumber.create!(fax_number_label: 'Fake Number 3', fax_number: '12025550126', client_id: fakers.id, fax_number_display_label: "Fake Sales")

phaxio_user3 = Email.create!(email: 'ceo@phaxio.com', fax_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user4 = Email.create!(email: 'cto@phaxio.com', fax_number: founder_num.fax_number, client_id: phaxio.id)
phaxio_user1 = Email.create!(email: 'marketing1@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user2 = Email.create!(email: 'marketing2@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user5 = Email.create!(email: 'developer1@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user6 = Email.create!(email: 'developer2@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)
phaxio_user7 = Email.create!(email: 'matt@phaxio.com', fax_number: dev_num.fax_number, client_id: phaxio.id)

fake1 = Email.create!(email: 'faker1@aol.com', fax_number: fake_num1.fax_number, client_id: fakers.id)
fake2 = Email.create!(email: 'faker2@aol.com', fax_number: fake_num1.fax_number, client_id: fakers.id)
fake3 = Email.create!(email: 'faker3@aol.com', fax_number: fake_num2.fax_number, client_id: fakers.id)

FaxNumberEmail.create!([
{email_id: phaxio_user1.id, fax_number_id: dev_num.id},
{email_id: phaxio_user2.id, fax_number_id: dev_num.id},
{email_id: phaxio_user5.id, fax_number_id: dev_num.id},
{email_id: phaxio_user6.id, fax_number_id: dev_num.id},
{email_id: phaxio_user7.id, fax_number_id: dev_num.id},
{email_id: phaxio_user3.id, fax_number_id: dev_num.id},
{email_id: phaxio_user3.id, fax_number_id: founder_num.id},
{email_id: phaxio_user4.id, fax_number_id: founder_num.id},

{email_id: fake1.id, fax_number_id: fake_num1.id},
{email_id: fake2.id, fax_number_id: fake_num1.id},
{email_id: fake3.id, fax_number_id: fake_num2.id},
])