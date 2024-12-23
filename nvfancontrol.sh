#!/bin/bash
if [ "$EUID" -ne 0 ]; then
	exec sudo bash "$0" "$@"
fi
while true; do
	echo "Which mode? (quiet/cool): "
	read -r MODE
	if [[ "$MODE" == "quiet" || "$MODE" == "cool" ]]; then
		break
	else
		echo "Invalid input. Please enter 'quiet' or 'cool'. Press Ctrl+C to cancel."
	fi
done
echo "Changing fan profile to $MODE"
echo "Stopping nvfancontrol service"
systemctl stop nvfancontrol
CONFIG_FILE="/etc/nvfancontrol.conf"
if [ -f "$CONFIG_FILE" ]; then
	echo "Editing FAN_DEFAULT_PROFILE to $MODE"
	sed -i "s/^[[:space:]]*FAN_DEFAULT_PROFILE[[:space:]].*/	FAN_DEFAULT_PROFILE $MODE/" "$CONFIG_FILE"
else
	echo "$CONFIG_FILE not found."
	exit 1
fi
STATUS_FILE="/var/lib/nvfancontrol/status"
if [ -f "$STATUS_FILE" ]; then
	echo "Removing nvfancontrol status file..."
	rm /var/lib/nvfancontrol/status
else
	echo "Status file not found."
fi
echo "Starting nvfancontrol service..."
systemctl start nvfancontrol
echo "nvfancontrol profile successfully changed to $MODE"
