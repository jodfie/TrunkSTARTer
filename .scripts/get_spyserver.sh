#!/bin/bash

CURDIR=$(pwd)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
YELLOW='\033[1;33m'

if [ "$EUID" -ne 0 ]
then 
	echo -e "${RED}Please run as root${NC}"
	exit
fi

# Get arch
ARCH=$(getconf LONG_BIT)

echo -e "\n\t${RED} Installing Airspy software ${GREEN}$ARCH bit ${NC}\n"

if [[ ! -d "$home/spyserver" ]]
then
	mkdir $home/spyserver
fi

if [[ -d "airspytmp" ]]
then
	rm -rf airspytmp
fi
mkdir airspytmp && cd airspytmp


# Install required packages
echo -e "${CYAN} Installing apt dependencies ${NC}"
apt update > /dev/null 2>&1
apt install -y git build-essential cmake libusb-1.0-0-dev pkg-config > /dev/null 2>&1

mkdir airspytmp && cd airspytmp

# Download airspy binaries
echo -e "${CYAN} Downloading airspy binaries $ARCH bits ${NC}"
wget https://airspy.com/?ddownload=4262 > /dev/null 2>&1
tar zxvf spyserver-linux-x64.tgz > /dev/null 2>&1

# Copy airspy to bin dir
echo -e "${CYAN} Installing airspy binaries ${NC}"
chmod +x spyserver spyserver_ping
cp spyserver spyserver_ping /usr/local/bin

# Copy default config examples
cp spyserver.config /home/$home/spyserver

# Installing libs for Airspy mini / R2
echo -e "${CYAN} Installing libs for Airspy mini/R2 ${NC}"
git clone https://github.com/airspy/airspyone_host.git > /dev/null 2>&1
cd airspyone_host
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON > /dev/null 2>&1
make > /dev/null 2>&1
make install > /dev/null 2>&1
cd ../../

# Running ldconfig
ldconfig

# Create default config examples
echo -e "${CYAN} Creating default config for Airspy mini"
cat <<EOF > $home/spyserver/spyserver.mini.config
# SPY Server Configuration File for Airspy Mini
bind_host = 0.0.0.0
bind_port = 5556
list_in_directory = 1
owner_name = John Doe
owner_email = john@doe.com
antenna_type = 
antenna_location =
general_description =
maximum_clients = 10
maximum_session_duration = 30
allow_control = 1
device_type = AirspyOne
device_serial = 0
device_sample_rate = 6000000
#force_8bit = 1
#maximum_bandwidth = 15000
fft_fps = 15
fft_bin_bits = 16
initial_frequency = 146000000
minimum_frequency = 24000000
maximum_frequency = 1750000000
#frequency_correction_ppb = 0
initial_gain = 10
#rtl_sampling_mode = 0
#converter_offset = -120000000
enable_bias_tee = 0
buffer_size_ms = 50
buffer_count = 10
EOF
echo -e "${CYAN} Creating default config for Airspy R2"
cat <<EOF > $home/spyserver/spyserver.r2.config
# SPY Server Configuration File for Airspy R2
bind_host = 0.0.0.0
bind_port = 5557
list_in_directory = 1
owner_name = John Doe
owner_email = john@doe.com
antenna_type = 
antenna_location =
general_description =
maximum_clients = 10
maximum_session_duration = 30
allow_control = 1
device_type = AirspyOne
device_serial = 0
device_sample_rate = 10000000
#force_8bit = 1
#maximum_bandwidth = 15000
fft_fps = 15
fft_bin_bits = 16
initial_frequency = 146000000
minimum_frequency = 24000000
maximum_frequency = 1750000000
#frequency_correction_ppb = 0
initial_gain = 10
#rtl_sampling_mode = 0
#converter_offset = -120000000
enable_bias_tee = 0
buffer_size_ms = 50
buffer_count = 10
EOF

echo -e "${CYAN} Creating default services"
cat <<EOF >/etc/systemd/system/spyserver@.service
[Unit]
Description=Spy Server %i
After=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
ExecStartPre=/usr/bin/test -f $home/spyserver/spyserver.%i.config
ExecStart=/usr/local/bin/spyserver $home/spyserver/spyserver.%i.config
User=pi

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo -e "\n${PURPLE}List of Airspy mini/R2 installed:${ORANGE}\n"
airspy_info

cd $CURDIR
rm -rf airspytmp

# Permissions
chown -R pi.pi $home/spyserver

# Final info
echo -e "
${RED}The example config template file is in ${YELLOW}$home/spyserver/spyserver.config ${NC}
${RED}The example config file for ${GREEN}Airspy mini${RED} is ${YELLOW}$home/spyserver/spyserver.mini.config ${NC}
${RED}The example config file for ${GREEN}Airspy R2${RED} is ${YELLOW}$home/spyserver/spyserver.r2.config ${NC}

${PURPLE}To enable Airspy mini at startup run ${GREEN} sudo systemctl enable spyserver@mini
${PURPLE}To start Airspy mini at startup run ${GREEN} sudo systemctl start spyserver@mini

${PURPLE}To enable Airspy R2 at startup run ${GREEN} sudo systemctl enable spyserver@r2
${PURPLE}To start Airspy R2 at startup run ${GREEN} sudo systemctl start spyserver@r2
${NC}"

# Install complete
echo -e "${GREEN} Install complete. Enjoy!${NC}\n"