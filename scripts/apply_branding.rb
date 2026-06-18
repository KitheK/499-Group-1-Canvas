# Apply Group 1 Canvas institution name and brand colors.
# Run inside canvas-lms-web container:
#   docker cp scripts/apply_branding.rb canvas-lms-web-1:/tmp/apply_branding.rb
#   docker exec canvas-lms-web-1 bundle exec rails runner /tmp/apply_branding.rb

PRIMARY = ENV.fetch("GROUP1_PRIMARY_COLOR", "#c75087")
INSTITUTION_NAME = ENV.fetch("GROUP1_INSTITUTION_NAME", "Group 1 Canvas")
THEME_NAME = ENV.fetch("GROUP1_THEME_NAME", "Group 1 Canvas Theme")

JS_OVERRIDES = <<~JS.squish
  document.title = '#{INSTITUTION_NAME}';
  var logo = document.querySelector('.ic-Login-header__logo img');
  if (logo) { logo.alt = '#{INSTITUTION_NAME}'; }
JS

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
].each { |key| vars[key] = PRIMARY }

theme = BrandConfig.new(
  variables: vars,
  share: false,
  name: THEME_NAME,
  js_overrides: JS_OVERRIDES,
)
theme.save_unless_dup!
theme.save_all_files!

account = Account.default
account.name = INSTITUTION_NAME
account.brand_config_md5 = theme.md5
account.save!

puts "Applied branding: #{account.name} (#{PRIMARY}) md5=#{theme.md5}"
