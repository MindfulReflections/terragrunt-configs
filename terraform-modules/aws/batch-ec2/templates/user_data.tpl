#!/bin/bash

# === SSH keys setup ===
mkdir -p /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh
cat > /home/ec2-user/.ssh/authorized_keys <<'SSHKEYS'
%{ for key in ssh_keys ~}
${key}
%{ endfor ~}
SSHKEYS
chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys

# === Remove static Amazon MOTD ===
rm -f /etc/motd

# === Create custom MOTD script ===
cat > /etc/update-motd.d/00-custom <<'EOF'
#!/bin/bash
echo " __  __   ____                             \\ | / "
echo "|  \\/  | |  _ \\     Mindful Reflections    (o o)"
echo "| |\\/| | | |_) |   ---------------------     ▼"
echo "| |  | | |  _ <     We don't just code.    <( )>"
echo "|_|  |_| |_| \\_\\                           ^^ ^^"
echo
echo "🕒 Uptime: $(uptime -p)"
echo "👤 Last login: $(last -n 2 | tail -n 1 | awk '{print $1, $4, $5, $6, $7}')"
echo "📦 Packages: $(rpm -qa | wc -l)"
EOF

chmod -x /etc/update-motd.d/*
chmod +x /etc/update-motd.d/00-custom

# === Create systemd service to generate /etc/motd ===
cat > /etc/systemd/system/motd-replace.service <<'EOF'
[Unit]
Description=Update /etc/motd with custom content
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "run-parts /etc/update-motd.d/ > /etc/motd"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable motd-replace.service
systemctl start motd-replace.service
