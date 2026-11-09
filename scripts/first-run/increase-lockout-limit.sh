# Increase lockout limit to 10 and decrease timeout to 2 minutes
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# No login-manager tweak needed: /etc/pam.d/greetd -> system-local-login ->
# system-login -> system-auth, so the greetd (tuigreet) login gets the same limits as
# hyprlock. faillock state lives in /run/faillock (tmpfs), so the counter
# resets on every restart, and a successful greetd/hyprlock login also resets
# it via system-auth's `pam_faillock.so authsucc`.
