<!-- [![Build Status](https://travis-ci.org/mwmayerle/new_phax_machine.svg?branch=master)](https://travis-ci.org/mwmayerle/new_phax_machine) -->

<!--------------------------------------------->

# PhaxMachine

## Introduction
PhaxMachine is a lightweight, customizable application that makes it easy for service providers to quickly provide and manage permission-based email-to-fax and fax-to-email services to their customers. Users are linked by an admin or a manager into groups that are emailed whenever a fax is sent or received on the fax number they're linked to. The application allows an admin to create an organization, invite a manager to manage the organization (optional), assign fax numbers to that organization, and link users to each fax number.

The application utilizes the [Phaxio API](https://www.phaxio.com/) for faxing, the [Mailgun API](https://www.mailgun.com/) for emailing, and [Devise](https://github.com/plataformatec/devise) for user authentication.

## Table of Contents
[Introduction](#Introduction)  
[Setup](#Setup)  
[User_Guide](#User Guide)

## Setup

### 1. Deploy PhaxMachine

#### The easy way (click this button):

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/mwmayerle/new_phax_machine)

You'll notice a number of fields that need to be populated (e.g. App Name and the Config Variables). Choose an App name, and populate the API credentials fields with your production [API credentials from Phaxio](https://console.phaxio.com/apiSettings).

Skip to section 2 below.

#### Or manually:

1. Install and configure the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).
   Create an account if you do not already have one.
2. Clone this repository: `git clone https://github.com/phaxio/new_phax_machine.git && cd new_phax_machine`
3. Create the app on Heroku: `heroku create`
4. Set the required environment variables:
	 - `heroku config:set ADMIN_EMAIL=Email address for the administrator`
	 - `heroku config:set DOMAIN_URL=The domain this application will be deployed to. If you're not using a custom domain this will be 'https://YOURAPPNAMEHERE.herokuapp.com'.`
	 - `heroku config:set FROM_EMAIL=The 'from' address attached to outgoing emails sent from the application.`
	 - `heroku config:set SMTP_PASSWORD=Mailgun's SMTP password for outgoing email.`
	 - `heroku config:set SMTP_USER=Mailgun's SMTP username for outgoing email.`
   - `heroku config:set PHAXIO_API_KEY=your_api_key`
   - `heroku config:set PHAXIO_API_SECRET=your_api_secret`
   - `heroku config:set PHAXIO_CALLBACK_TOKEN=your_callback_token`
5. Deploy: `git push heroku master`

### 2. Configure Mailgun (we'll come back to the fields on Heroku soon):

1. Sign up for a [Mailgun](https://www.mailgun.com) account.
2. In the Mailgun console, choose the "Domains" tab, then click the "Add New Domain" button, and enter the subdomain where you want to receive fax emails. In these examples, I'm using `phaxmail.myapp.com`. If you don't want to configure your own domain, you can use the sandbox domain already in your Mailgun account, but you'll have to manually add permitted user emails for the domain on Mailgun. If you're using the sandbox domain, you can skip to step 4 below.
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun Add Domain Button Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_add_domain.png)
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun Add Domain Form Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_add_domain_form.png)
3. Verify your domain. Mailgun will provide you with straight-forward guides on how to do this with most common providers. This step may take some time.
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun Verify Domain Page Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domain_verification.png)
4. On the [domains page](https://app.mailgun.com/app/domains), select the domain that you'll be using. (This can be the sandbox domain in your account which ends mailgun.org.)
5. In the Domain Information section, copy and paste the SMTP Hostname into the SMTP_HOST field on Heroku.
6. Next copy and past the Default SMTP Login from Mailgun into the SMTP_USER field on Heroku.
7. Copy and paste the Default Password from Mailgun into the SMTP_PASSWORD field on Heroku.
8. Use port 587 as the SMTP port, mark SMTP_TLS as true, and enter the email address you'd like the emails to come from in the SMTP_FROM field.
9. Click Deploy!
10. Once your domain at Mailgun has been verified, choose the "Routes" tab, then click the "Create a Route" button
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun Routes Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_routes_tab.png)
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun Create Route Button Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_route_add_button.png)
11. On the "Create New Route" page, choose "Match Recipient" for the Expression Type, and in the Recepient field enter the following pattern (substituting the domain you previously configured): `[0-9]+@phaxmail.myapp.com`. Then, under "Actions", tick the "Forward" box and enter the URL for your instance of PhaxMachine, followed by `/mailgun` (e.g. If you're using a quick and dirty Heroku installation, this url might look something like https://WHATYOUNAMEDYOURAPP.herokuapp.com/mailgun.) The other fields should be left alone, and once you're finished click the "Create Route" button.
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun New Route Page Screenshot 1](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_new_route_1.png)
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Mailgun New Route Page Screenshot 2](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_new_route_2.png)
12. (Optional, only needed if you want to test that fax-to-email and email-to-fax are working) Open your instance of PhaxMachine, click on the "Manage Users" link at the top, and add create a user with your email and phaxio fax number.
13. (Optional) Test that everything is working correctly by sending an email with an attachment in the following format: `15551231234@phaxmail.myapp.com` (substituting the phone number and domain). **Phone Numbers should not contain any special characters.** If everything is set up correctly, you should have just sent a fax.
![Mailgun Domains Tab Screenshot](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/mailgun_domains_tab.png)
![Email Example](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/phaxio_email.png)

### Setting up Fax --> Email
1. Head to the [Callback URL's page in Phaxio](https://console.phaxio.com/user/callbacks/edit).
2. In the second field which says "POST (or send email) to the above URL when a fax has been received," enter your application url followed by '/fax_received' (e.g. If you're using a quick and dirty Heroku installation, this url might look something like https://WHATYOUNAMEDYOURAPP.herokuapp.com/fax_received. *Note:* if you're using the quick and dirty setup, your faxing emails might be in your spam folder! )

3. (Optional) Test the everything is working correctly by sending a fax to your Phaxio number and and seeing if it shows up in your email inbox! Note: make sure to check your spam folder!

## Updating an app deployed using the "Deploy" button

If you want to merge the latest code from this repository into a PhaxMachine instance deployed with
the button above, you'll need to follow these instructions:

1. Clone this repository: `git clone https://github.com/phaxio/phax_machine.git`
2. Add the heroku repository as well: `git remote add heroku https://git.heroku.com/HEROKU-APP-NAME.git` (Substituting `HEROKU-APP-NAME` with the name of your Heroku app)
3. Push the latest changes to Heroku: `git push heroku master`

## User Guide/Walkthrough
After initial setup is complete, an email will be sent to the address in the "ADMIN_EMAIL" field inviting the admin to set their password and finish setting up their account. The admin will then be redirected to the fax numbers page. 

### Admin Functions
#### Managing Fax Numbers
The Fax Numbers page displays a table of all fax numbers in the admin's account, the organization the fax number is linked to, an optional label, the date the fax number was provisioned, the location of the fax number, and whether or not the fax number has a 'callback_url' assigned to it. Fax numbers with an assigned callback_url will not work with Phax Machine. To manage callback_url's assigned to your fax numbers, head over to your [phone numbers page](https://console.phaxio.com/phone_numbers) in your Phaxio account, and then reload the Fax Numbers page when you're done editing your changes. Fax numbers with an assigned callback_url will be at the bottom of the fax numbers table. In the example below, several lines have already been labeled.

![FaxNumberPage](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/faxnumberpage.png)

The top of the Fax Numbers page also allows the Admin to provision a new fax number. The Area Code dropdown menu dynamically changes based on the selected State/Province in the menu to the left. Toll-Free numbers are listed as "Non-Geographic" in State/Province.

If the Admin desires, they may add a label to any fax number that can only be viewed by the Admin by clicking one of the edit buttons on the right of the table. The Admin can also move the fax number into a different organization by selecting it from the dropdown menu (this will remove all users linked to the number in its previous organization), or remove the fax number from its organization.

![EditFaxNumberPage](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/editfaxnumberpage.png)

#### Managing Organizations
Organizations are groups of users and fax numbers set by the Admin. To create an organization, navigate to the Organizations Page ("Organizations" on the navbar) and click the "Add New Organization" button in the top right corner of the screen.

This page displays all fax numbers that are not assigned to a organization in the "Add fax numbers" table. Please note that fax numbers with a red X next to them already have a primary callback_url will not have fax-to-email capabilities.

![NewOrganization](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/neworganization.png)

When creating an organization, the Admin checks the box of fax numbers they would like to assign to the organization, gives the organization a name (this name will be seen by the organization's manager), and decides if the Manager of the organization will be allowed to purchase additional fax numbers. In this example we're creating the "Great Plains LLC" organization, adding all of the fax numbers that are already labeled, and allowing fax numbers to be purchased by the organization. 

Once an organization has been created, it will appear in the organization page. Each organization's fax numbers and manager (if it has one) are shown. If an organization does not have a manager, a field will be present for inviting a manager, with an additional dropdown menu of fax numbers to set as the manager's caller ID number. In this example we'll invite bob.loblaw@greatplainsllc.com to manage Great Plains LLC.

![OrganizationIndex](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/organizationindex.png)

If an admin would like to edit an organization, they can click on the organization's name, which takes them to a page displaying all of the users linked to a particular fax number. Users may be linked to multiple fax numbers or just one, depending on the use case. When a fax number receives a fax, every person linked to that number will be emailed. To edit the organization, click on the "Manage Great Plains LLC Fax Numbers/Details" in the upper right corner.

![OrganzationShow](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/organizationshow.png)

In this case we'll simultaneously remove the two fax numbers that have a different callback_url and add the 971 number to this organization.

![OrganizationEdit](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/organizationedit.png)

### Manager Functions
Managers are invited by the Admin via email to manage an organization. Each organization may only have one manager. Managers (and the admin if they want to) link users to fax numbers and assign them caller ID numbers. If the admin allows it, a manager can also provision additional fax numbers to the organization they control. Managers should first invite users and then link them to fax numbers. Users who are not linked to a fax number by the manager will be able to log in and send a fax with the fax portal, however they will not be notified when a fax is received.

#### Users
Managers may invite users to Phax Machine and revoke user access in their Users portal. When a manager invites a user, they input a valid email address and select one of the fax numbers within their organization from the dropdown menu. Managers may also edit an existing user's email address or caller ID number at a later time.

#### Dashboard
The dashboard provides the manager with a summary of all fax numbers and their linked users. Managers can add a label to their fax numbers by clicking on the fax number and link/unlink users to a fax numbers by clicking on the "Link/Unlink Users" button under each fax number. A table of all users currently linked to a fax number is shown next to each fax number.

![UserShow](https://raw.githubusercontent.com/mwmayerle/new_phax_machine/master/app/assets/images/userspage.png)
