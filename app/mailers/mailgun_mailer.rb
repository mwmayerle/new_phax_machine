class MailgunMailer < ApplicationMailer
	def fax_sent(sender, client)
  	@sender = sender
  	@client = client
  	mail(
  		to: @sender.email_address,
  		from: ENV["FROM_EMAIL"],
  		template: 'fax_sent',
  	)
  end

  def fax_received
  end
end
