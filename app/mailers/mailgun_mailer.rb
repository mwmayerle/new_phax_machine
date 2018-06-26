class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_sent(fax_sender, email_subject, fax)
  	@sender = sender
  	@client = sender.client
  	@fax = fax
  	mail(
  		to: @sender.email_address,
  		subject: email_subject,
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
