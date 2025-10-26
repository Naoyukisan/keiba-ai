# Pin npm packages by running ./bin/importmap

pin "application"

# config/importmap.rb

pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.18
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3

pin "jquery" # @3.7.1
pin "jquery-ui" # @1.14.1
pin "bootstrap" # @5.3.8

# 重要：ESM の popper を指す
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/dist/esm/popper.js"

pin "flatpickr" # @4.6.13
pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js" # @7.1.0

# rails_admin（generator が作成したエントリを読む）
pin "rails_admin", to: "rails_admin.js"
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.18
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.1.0
