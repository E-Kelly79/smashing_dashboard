# **[Smashing](https://smashing.github.io/) RouteMatch specification**

## How to run Docker container with the dashboard
`cd com-docker-dashing/Docker/`
`docker build –t smashing .`
`docker run -d -p 8080:3030 smashing`

## How to access the dashboard 
Enter the following URL into a browser:
- `http://172.25.1.10:8080 (Development Environment)`
- `http://10.128.5.92:8080 (AWS Instance)`

## How to setup Raspberry Pi for the dashboard
- Download and install [Raspbian OS](https://www.raspberrypi.org/downloads/raspbian/)
- Install [Chromium Browser](https://download-chromium.appspot.com/)
- Copy `kiosk.desktop` file from this repo to `/home/pi/.config/autostart/`
- Copy `dashboard_load.sh` script from this repo to `/home/pi/`
- Disable screensaver using xscreensaver: `sudo apt-get install xscreensaver`
- Run xscreensaver, then navigate to `preference>screensaver>Disable`
- Connect to RouteMatch Wi-Fi and restart Pi