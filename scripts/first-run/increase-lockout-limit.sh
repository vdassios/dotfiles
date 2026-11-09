# Increase lockout limit to 10 and decrease timeout to 2 minutes
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# No login-manager tweak needed: greetd's autologin (initial_session) skips
# PAM auth entirely, and faillock state lives in /run/faillock (tmpfs), so the
# counter already resets on every restart. A successful hyprlock/greetd
# password login also resets it via system-auth's `pam_faillock.so authsucc`.
