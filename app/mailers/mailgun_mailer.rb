class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_sent(fax_sender, email_subject, fax)
  	@fax_sender = fax_sender
  	@client = fax_sender.client
  	@fax = fax
  	@email_subject = email_subject
  	mail(
  		to: @sender.email_address,
  		subject: @email_subject,
  		template: 'fax_sent',
  	)
  end

  def fax_received(sender, client)
  	@sender = sender
  	@client = client
  	mail(
  		to: @sender.email_address,
  	)
  end
end
