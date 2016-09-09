ActionMailer::Base.smtp_settings = {
	:address   => "smtp.gmail.com",
	:port      =>  587,
	:domain    =>  "bytemap.com",
	:user_name =>  "bytemap.offer",
	:password  =>  "bytemap123",
	:authentication  => "plain",
	:enable_starttls_auto => true
}