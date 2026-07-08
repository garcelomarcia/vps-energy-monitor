# VPS Energy Monitor

Estimate the energy consumption and CO2e emissions of an Ubuntu VPS using transparent CPU and RAM-based calculations.

VPS Energy Monitor is a lightweight command-line tool. It runs as a `systemd` service, stores local metrics in SQLite, and generates terminal reports for the last day, week, or month.

## Why this exists

Most VPS providers do not expose real-time physical power consumption per virtual machine. This tool provides an estimation model based on allocated virtual resources and actual utilization inside the VPS.

## Important limitation

This is an estimation, not a physical power meter. VPS environments share physical servers with other tenants, so the tool cannot know the exact electricity consumed by the underlying host.

For formal reporting, use your provider's official carbon or environmental impact report whenever available.

## Formula

For a VPS without GPU:

```text
Energy kWh =
hours x ((vCPU x W_per_vCPU x CPU_usage)
+ (RAM_GB x W_per_GB_RAM)) / 1000 x PUE
```

Emissions:

```text
CO2e =
Energy kWh x grid_emission_factor
```

Where:

- `vCPU`: number of virtual CPUs assigned to the VPS
- `W_per_vCPU`: estimated watts per vCPU at 100% utilization
- `CPU_usage`: average CPU usage as a decimal
- `RAM_GB`: allocated or used RAM, depending on `RAM_MODE`
- `W_per_GB_RAM`: estimated watts per GB of RAM
- `PUE`: Power Usage Effectiveness of the data center
- `grid_emission_factor`: kgCO2e per kWh for the data center region

## Installation

```bash
git clone https://github.com/YOUR-USER/vps-energy-monitor.git
cd vps-energy-monitor
sudo ./install.sh
```

The installer copies:

- `bin/vps-energy` to `/usr/local/bin/vps-energy`
- `config/vps-energy.conf.example` to `/etc/vps-energy.conf` if no config exists
- `systemd/vps-energy.service` to `/etc/systemd/system/vps-energy.service`

It also creates `/var/lib/vps-energy` and starts the collector service.

## Configuration

Edit:

```bash
sudo nano /etc/vps-energy.conf
```

Example:

```bash
SAMPLE_INTERVAL=60
W_PER_VCPU=15
W_PER_GB_RAM=0.4
PUE=1.2
KGCO2E_PER_KWH=0.05
RAM_MODE=allocated
DB_PATH=/var/lib/vps-energy/vps-energy.db
```

The most important fields are:

- `W_PER_VCPU`: estimated watts per vCPU at 100% usage
- `PUE`: data center power usage effectiveness
- `KGCO2E_PER_KWH`: electricity emission factor for the VPS region
- `RAM_MODE`: `allocated` for assigned RAM, or `used` for actual used RAM

## Usage

Check service status:

```bash
sudo systemctl status vps-energy
```

Check the latest sample:

```bash
vps-energy status
```

Generate reports:

```bash
vps-energy report --period day
vps-energy report --period week
vps-energy report --period month
```

Generate all reports:

```bash
vps-energy report
```

Collect one sample manually:

```bash
sudo vps-energy collect --once
```

## Local development

The CLI has no third-party Python dependencies. For a local database:

```bash
VPS_ENERGY_DB=./vps-energy.db python3 bin/vps-energy collect --once
VPS_ENERGY_DB=./vps-energy.db python3 bin/vps-energy status
VPS_ENERGY_DB=./vps-energy.db python3 bin/vps-energy report --period day
```

The collector reads Linux metrics from `/proc/stat` and `/proc/meminfo`, so collection requires Linux.

## Uninstall

```bash
sudo ./uninstall.sh
```

The uninstaller keeps:

- `/var/lib/vps-energy/`
- `/etc/vps-energy.conf`

Remove them manually if you want a full cleanup.

## Roadmap

- [ ] Add CSV export
- [ ] Add JSON report output
- [ ] Add provider presets for OVH, AWS, Azure, DigitalOcean, and Hetzner
- [ ] Add region-based emission factor examples
- [ ] Add optional GPU support
- [ ] Add dashboard mode
- [ ] Add GitHub Actions for linting

## License

MIT License.
