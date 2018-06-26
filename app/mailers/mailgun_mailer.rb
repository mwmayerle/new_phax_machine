class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_sent(sender, client)
  	@sender = sender
  	@client = client
  	mail(
  		to: @sender.email_address,
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
