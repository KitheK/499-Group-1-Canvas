# Apply Group 1 Canvas institution name, brand colors, and custom login page.
# Run inside canvas-lms-web container:
#   docker cp scripts/apply_branding.rb canvas-lms-web-1:/tmp/apply_branding.rb
#   docker exec canvas-lms-web-1 bundle exec rails runner /tmp/apply_branding.rb

PRIMARY = ENV.fetch("GROUP1_PRIMARY_COLOR", "#c75087")
INSTITUTION_NAME = ENV.fetch("GROUP1_INSTITUTION_NAME", "Group 1 Canvas")
THEME_NAME = ENV.fetch("GROUP1_THEME_NAME", "Group 1 Canvas Theme")
WELCOME_HEADING = ENV.fetch("GROUP1_WELCOME_HEADING", "Welcome to Team 1 Canvas")
WELCOME_SUBTITLE = ENV.fetch("GROUP1_WELCOME_SUBTITLE", "Sign in with your team account to access courses")

JS_OVERRIDES = <<~JS.squish
  (function () {
    document.title = '#{INSTITUTION_NAME}';
    var inner = document.querySelector('.ic-Login__innerContent');
    if (!inner || document.querySelector('.group1-login-welcome')) return;

    var welcome = document.createElement('div');
    welcome.className = 'group1-login-welcome';
    welcome.innerHTML =
      '<h1>#{WELCOME_HEADING}</h1>' +
      '<p>#{WELCOME_SUBTITLE}</p>';

    var body = inner.querySelector('.ic-Login__body');
    if (body) {
      inner.insertBefore(welcome, body);
    } else {
      inner.insertBefore(welcome, inner.firstChild);
    }

    var logoWrap = inner.querySelector('.ic-Login-header__logo');
    if (logoWrap) logoWrap.style.display = 'none';
  })();
JS

CSS_OVERRIDES = <<~CSS
  .ic-Login-Body {
    background: linear-gradient(145deg, #fdf2f7 0%, #f7f7f7 45%, #ececec 100%) !important;
  }

  .ic-Login__content {
    border-radius: 14px !important;
    box-shadow: 0 12px 40px rgba(199, 80, 135, 0.18) !important;
    overflow: hidden;
  }

  .group1-login-welcome {
    text-align: center;
    padding: 2rem 2rem 1.25rem;
    border-bottom: 1px solid rgba(199, 80, 135, 0.15);
    background: linear-gradient(180deg, rgba(199, 80, 135, 0.08) 0%, rgba(255, 255, 255, 0) 100%);
  }

  .group1-login-welcome h1 {
    color: #{PRIMARY};
    font-size: 1.85rem;
    font-weight: 700;
    margin: 0 0 0.6rem;
    letter-spacing: -0.02em;
    line-height: 1.25;
  }

  .group1-login-welcome p {
    color: #5c5c5c;
    font-size: 1rem;
    margin: 0;
    line-height: 1.45;
  }

  .ic-Login__body {
    padding-top: 0.5rem !important;
  }

  .ic-Login-header {
    padding-bottom: 0 !important;
  }

  .Button--login {
    border-radius: 8px !important;
    font-weight: 600 !important;
    letter-spacing: 0.01em;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
  }

  .Button--login:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(199, 80, 135, 0.35);
  }

  .ic-Input.text:focus {
    border-color: #{PRIMARY} !important;
    box-shadow: 0 0 0 2px rgba(199, 80, 135, 0.2) !important;
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
].each { |key| vars[key] = PRIMARY }

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
