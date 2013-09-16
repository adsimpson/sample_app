include ApplicationHelper

def sign_in(user, options={})
  if options[:no_capybara]
    # Sign in when not using Capybara.
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path    
    fill_in "Email",           with: user.email
    fill_in "Password",        with: user.password
    click_button "Sign in"
  end
end

def invalid_sign_in
  visit signin_path    
  click_button "Sign in"
end

def sign_up(user)
  fill_in "Name",              with: user.name
  fill_in "Email",             with: user.email
  fill_in "Password",          with: user.password
  fill_in "Confirmation",      with: user.password
  click_button "Create my account"
end

def invalid_sign_up
  click_button "Create my account"
end

def edit_profile(new, user)
  fill_in "Name",             with: new[:name]
  fill_in "Email",            with: new[:email]
  fill_in "Password",         with: user.password
  fill_in "Confirm Password", with: user.password_confirmation
  click_button "Save changes"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end