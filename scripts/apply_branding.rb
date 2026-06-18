# Apply Group 1 Canvas institution name and brand colors.
# Run inside canvas-lms-web container:
#   bundle exec rails runner /path/to/apply_branding.rb
# Or from host:
#   docker exec canvas-lms-web-1 bundle exec rails runner /usr/src/app/../apply_branding.rb

PRIMARY = ENV.fetch("GROUP1_PRIMARY_COLOR", "#c75087")
INSTITUTION_NAME = ENV.fetch("GROUP1_INSTITUTION_NAME", "Group 1 Canvas")
THEME_NAME = ENV.fetch("GROUP1_THEME_NAME", "Group 1 Canvas Theme")

base = BrandConfig.first
raise "No base BrandConfig found" unless base

vars = base.variables.deep_dup
vars["ic-brand-primary"] = PRIMARY
vars["ic-brand-Login-Content-button-bgd"] = PRIMARY
vars["ic-brand-Login-footer-link-color"] = PRIMARY
vars["ic-link-color"] = PRIMARY
vars["ic-brand-global-nav-logo-bgd"] = PRIMARY
vars["ic-brand-button--primary-bgd"] = PRIMARY

theme = BrandConfig.new(variables: vars, share: false, name: THEME_NAME)
theme.save_unless_dup!

account = Account.default
account.name = INSTITUTION_NAME
account.brand_config_md5 = theme.md5
account.save!

puts "Applied branding: #{account.name} (#{PRIMARY}) md5=#{theme.md5}"
