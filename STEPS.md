sudo apt update
sudo apt upgrade
# CHROME
sudo apt install chromium
cd Downloads/
# VSCODE
sudo apt install ./code_1.131.0-1785237861_amd64.deb
# UPWORK
bash upwork.sh
# CLAMAV - ANTIVIRUS
sudo apt update
sudo apt install -y clamav clamav-daemon clamtk
sudo systemctl stop clamav-freshclam || true
sudo freshclam
sudo systemctl enable clamav-freshclam
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon
sudo usermod -aG clamav "$USER"
# DRsprinto
bash drsprinto.sh
# GIT, GITHUB & SSH
bash git-ssh.sh
sudo snap install gh --classic
gh auth login
