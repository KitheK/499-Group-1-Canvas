# Apply Group 1 Canvas branding — login page matches stitch_canvas_lms_login_design/DESIGN.md
# Run: docker cp scripts/apply_branding.rb canvas-lms-web-1:/tmp/apply_branding.rb
#      docker exec canvas-lms-web-1 bundle exec rails runner /tmp/apply_branding.rb

PRIMARY = ENV.fetch("GROUP1_PRIMARY_COLOR", "#c75087")
INSTITUTION_NAME = ENV.fetch("GROUP1_INSTITUTION_NAME", "Canvas LMS Group 1")
THEME_NAME = ENV.fetch("GROUP1_THEME_NAME", "Group 1 Canvas Theme")
WELCOME_HEADING = ENV.fetch("GROUP1_WELCOME_HEADING", "Welcome back")
WELCOME_SUBTITLE = ENV.fetch("GROUP1_WELCOME_SUBTITLE", "Please enter your details to sign in.")

JS_OVERRIDES = <<~JS.squish
  (function () {
    document.title = '#{INSTITUTION_NAME}';

    if (!document.querySelector('.group1-page-brand')) {
      var pageBrand = document.createElement('div');
      pageBrand.className = 'group1-page-brand';
      pageBrand.textContent = '#{INSTITUTION_NAME}';
      document.body.insertBefore(pageBrand, document.body.firstChild);
    }

    var inner = document.querySelector('.ic-Login__innerContent');
    if (!inner) return;

    var logoWrap = inner.querySelector('.ic-Login-header__logo');
    if (logoWrap) logoWrap.style.display = 'none';
    var headerLinks = inner.querySelector('.ic-Login-header__links');
    if (headerLinks) headerLinks.style.display = 'none';
    var header = inner.querySelector('.ic-Login-header');
    if (header) header.style.display = 'none';

    if (!document.querySelector('.group1-login-welcome')) {
      var welcome = document.createElement('div');
      welcome.className = 'group1-login-welcome';
      welcome.innerHTML =
        '<h1>#{WELCOME_HEADING}</h1>' +
        '<p>#{WELCOME_SUBTITLE}</p>';
      var body = inner.querySelector('.ic-Login__body');
      if (body) inner.insertBefore(welcome, body);
    }

    var loginBtn = document.querySelector('#login_form input[type=submit], #login_form .Button--login');
    if (loginBtn) loginBtn.value = 'Sign in';

    var footer = document.querySelector('.ic-Login-footer');
    if (footer && !document.querySelector('.group1-login-footer')) {
      footer.innerHTML =
        '<div class="group1-login-footer">' +
          '<div class="group1-login-footer__left">' +
            '<strong>#{INSTITUTION_NAME}</strong>' +
            '<span>&copy; ' + new Date().getFullYear() + ' #{INSTITUTION_NAME}. All rights reserved.</span>' +
          '</div>' +
          '<div class="group1-login-footer__links">' +
            '<a href="#">Help</a>' +
            '<a href="#">Privacy Policy</a>' +
            '<a href="#">Terms of Service</a>' +
          '</div>' +
        '</div>';
    }
  })();
JS

CSS_OVERRIDES = <<~CSS
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

  .ic-Login-Body,
  .ic-Login-Body.full-width {
    background: #fff8f8 !important;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
    min-height: 100vh;
    position: relative;
    padding: 0 !important;
  }

  .group1-page-brand {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 10;
    padding: 24px 40px;
    font-size: 20px;
    font-weight: 700;
    letter-spacing: -0.02em;
    color: #{PRIMARY};
    background: transparent;
    pointer-events: none;
  }

  .ic-Login {
    min-height: 100vh;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 96px 24px 120px !important;
    box-sizing: border-box;
  }

  .ic-Login__container {
    width: 100%;
    max-width: 440px !important;
    margin: 0 auto !important;
  }

  .ic-Login__content {
    background: #ffffff !important;
    border: 1px solid #e5e7eb !important;
    border-radius: 16px !important;
    box-shadow: 0 4px 12px rgba(17, 24, 39, 0.08) !important;
    overflow: hidden;
  }

  .ic-Login__innerContent {
    padding: 0 !important;
  }

  .group1-login-welcome {
    text-align: left;
    padding: 32px 32px 8px;
  }

  .group1-login-welcome h1 {
    color: #23191c;
    font-size: 24px;
    font-weight: 600;
    line-height: 32px;
    margin: 0 0 8px;
    letter-spacing: -0.01em;
  }

  .group1-login-welcome p {
    color: #554248;
    font-size: 16px;
    font-weight: 400;
    line-height: 24px;
    margin: 0;
  }

  .ic-Login__body {
    padding: 16px 32px 32px !important;
  }

  .ic-Login__body .ic-Label {
    color: #23191c !important;
    font-size: 14px !important;
    font-weight: 600 !important;
    line-height: 20px !important;
    margin-bottom: 8px !important;
  }

  .ic-Login__body .ic-Form-control--login {
    margin-bottom: 20px !important;
  }

  .ic-Login__body .ic-Input.text {
    width: 100% !important;
    box-sizing: border-box;
    border: 1px solid #e5e7eb !important;
    border-radius: 8px !important;
    padding: 12px 14px 12px 42px !important;
    font-size: 16px !important;
    line-height: 24px !important;
    color: #23191c !important;
    background-color: #ffffff !important;
    background-repeat: no-repeat !important;
    background-position: 14px center !important;
    transition: border-color 0.15s ease, box-shadow 0.15s ease;
  }

  .ic-Login__body .ic-Form-control--login:first-of-type .ic-Input.text {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' fill='none' viewBox='0 0 24 24'%3E%3Cpath stroke='%23887178' stroke-width='1.8' d='M4 6h16v12H4z'/%3E%3Cpath stroke='%23887178' stroke-width='1.8' d='m4 7 8 6 8-6'/%3E%3C/svg%3E") !important;
  }

  .ic-Login__body .ic-Form-control--login:nth-of-type(2) .ic-Input.text {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' fill='none' viewBox='0 0 24 24'%3E%3Crect x='5' y='11' width='14' height='10' rx='2' stroke='%23887178' stroke-width='1.8'/%3E%3Cpath stroke='%23887178' stroke-width='1.8' d='M8 11V8a4 4 0 1 1 8 0v3'/%3E%3C/svg%3E") !important;
  }

  .ic-Login__body .ic-Input.text:focus {
    border-color: #{PRIMARY} !important;
    box-shadow: 0 0 0 3px rgba(199, 80, 135, 0.18) !important;
    outline: none !important;
  }

  .ic-Login__actions {
    margin-top: 8px !important;
  }

  .ic-Login__actions-timeout {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    margin-bottom: 24px !important;
    width: 100%;
  }

  .ic-Login__forgot .ic-Login__link,
  .ic-Login__link.forgot_password_link {
    color: #{PRIMARY} !important;
    font-size: 14px !important;
    font-weight: 500 !important;
    text-decoration: none !important;
  }

  .ic-Login__forgot .ic-Login__link:hover,
  .ic-Login__link.forgot_password_link:hover {
    text-decoration: underline !important;
  }

  .ic-Login__body label[for=pseudonym_session_remember_me] {
    color: #554248 !important;
    font-size: 14px !important;
  }

  .ic-Login__body .Button--login,
  .ic-Login__body input.Button--login {
    width: 100% !important;
    display: block !important;
    background: #{PRIMARY} !important;
    border: none !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-size: 16px !important;
    font-weight: 600 !important;
    padding: 14px 16px !important;
    cursor: pointer;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
  }

  .ic-Login__body .Button--login:hover,
  .ic-Login__body input.Button--login:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(199, 80, 135, 0.35);
  }

  .ic-Login-footer {
    position: fixed !important;
    bottom: 0 !important;
    left: 0 !important;
    right: 0 !important;
    background: #fff8f8 !important;
    border-top: 1px solid #e5e7eb !important;
    padding: 20px 40px !important;
    margin: 0 !important;
  }

  .group1-login-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    max-width: 1200px;
    margin: 0 auto;
    flex-wrap: wrap;
  }

  .group1-login-footer__left {
    display: flex;
    flex-direction: column;
    gap: 4px;
    color: #554248;
    font-size: 12px;
    line-height: 16px;
  }

  .group1-login-footer__left strong {
    color: #23191c;
    font-size: 14px;
    font-weight: 600;
  }

  .group1-login-footer__links {
    display: flex;
    gap: 24px;
    flex-wrap: wrap;
  }

  .group1-login-footer__links a {
    color: #554248 !important;
    font-size: 12px !important;
    font-weight: 500 !important;
    text-decoration: none !important;
  }

  .group1-login-footer__links a:hover {
    color: #{PRIMARY} !important;
  }

  @media (max-width: 640px) {
    .group1-page-brand {
      padding: 16px;
      font-size: 18px;
    }

    .ic-Login {
      padding: 72px 16px 140px !important;
    }

    .group1-login-welcome,
    .ic-Login__body {
      padding-left: 24px !important;
      padding-right: 24px !important;
    }

    .group1-login-footer {
      flex-direction: column;
      align-items: flex-start;
    }

    .ic-Login-footer {
      padding: 16px !important;
    }
  }
CSS

base = BrandConfig.first
raise "No base BrandConfig found" unless base

vars = base.variables.deep_dup
[
  "ic-brand-primary",
  "ic-brand-Login-Content-button-bgd",
  "ic-brand-Login-footer-link-color",
  "ic-link-color",
  "ic-brand-global-nav-logo-bgd",
  "ic-brand-button--primary-bgd",
  "ic-brand-Login-Content-border-color",
  "ic-brand-Login-body-bgd-color",
  "ic-brand-Login-Content-bgd-color",
].each { |key| vars[key] = PRIMARY if key.include?("button") || key.include?("primary") || key.include?("link") || key.include?("logo") }
vars["ic-brand-Login-body-bgd-color"] = "#fff8f8"
vars["ic-brand-Login-Content-bgd-color"] = "#ffffff"
vars["ic-brand-Login-Content-border-color"] = "#e5e7eb"

theme = BrandConfig.new(
  variables: vars,
  share: false,
  name: THEME_NAME,
  js_overrides: JS_OVERRIDES,
  css_overrides: CSS_OVERRIDES,
)
theme.save_unless_dup!
theme.save_all_files!

account = Account.default
account.name = INSTITUTION_NAME
account.brand_config_md5 = theme.md5
account.save!

puts "Applied branding: #{account.name} (#{PRIMARY}) md5=#{theme.md5}"
