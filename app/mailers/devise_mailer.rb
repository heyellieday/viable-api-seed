class DeviseMailer < Devise::Mailer

	include Devise::Controllers::UrlHelpers

	def confirmation_instructions(record, token, opts={})
  options = {
    :subject => "Confirm Email for #{ENV['site_name']}",
    :email => record.email,
    :global_merge_vars => [
      {
        name: 'email',
        content: record.email
      },
      {
        name: 'confirmation_link',   
        content: ENV['SERVER_BASE_URL'] +  '/confirm_email?token=' +token # ENV['SERVER_BASE_URL'] +  '/auth/confirmation?confirmation_token=' +token
      },
      {
        name: 'name',
        content:  record.name 
      }

    ],

    :template => "Email Confirm"
  }
  mandrill_send(options)
end

  
  def reset_password_instructions(record, token, opts={})
    options = {
      :subject => "Password Reset",
      :email => record.email,
      :global_merge_vars => [
        {
          name: "password_reset_link",
          content: "http://www.example.com/users/password/edit?reset_password_token=#{token}"
        }
      ],
      :template => "Forgot Password"
    }
    mandrill_send options  
  end
  
  def unlock_instructions(record, token, opts={})
    # code to be added here later
  end
  
  def mandrill_send(opts={})
    message = { 
      :subject=> "#{opts[:subject]}", 
      :from_name=> "Amplive",
    
      :from_email=>ENV['from_email'],
      :to=>
            [{"name"=>"Some User",
                "email"=>"#{opts[:email]}",
                "type"=>"to"}],
      :global_merge_vars => opts[:global_merge_vars]
      }
    sending = MANDRILL.messages.send_template opts[:template], [], message
    rescue Mandrill::Error => e
      Rails.logger.debug("#{e.class}: #{e.message}")
      raise
  end
end
