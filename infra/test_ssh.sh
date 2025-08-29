# Step: Test SSH connectivity to EC2 instance and report result
# Usage: ./test_ssh.sh <public_ip>
IP="$1"
KEY="$(dirname "$0")/id_rsa"
USER="ec2-user"

if [ -z "$IP" ]; then
  echo "Usage: $0 <public_ip>"
  exit 1
fi

# Test ping
ping -c 3 "$IP" > /dev/null 2>&1
PING_STATUS=$?

if [ $PING_STATUS -ne 0 ]; then
  echo "ERROR: Instance $IP is not reachable via ICMP (ping)."
  echo "Debug: Possible causes include AWS Security Group, NACL, or OS firewall blocking ICMP."
  echo "Run: aws ec2 describe-security-groups, check NACLs, and verify OS firewall settings."
else
  echo "Ping to $IP successful."
fi

# Test SSH
ssh -i "$KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$USER@$IP" "echo 'SSH connection successful.'" > /dev/null 2>&1
SSH_STATUS=$?

if [ $SSH_STATUS -ne 0 ]; then
  echo "ERROR: SSH connection to $IP failed."
  echo "Debug: Possible causes include AWS Security Group, NACL, OS firewall, or incorrect key/user."
  echo "Run: aws ec2 describe-security-groups, check NACLs, verify OS firewall, and ensure key/user are correct."
else
  echo "SSH connection to $IP successful."
fi

if [ $PING_STATUS -ne 0 ] || [ $SSH_STATUS -ne 0 ]; then
  exit 1
fi

exit 0
