## ardupilot-simulation

This workspace helps you run **ArduPilot SITL with Gazebo (Harmonic)**.

### Setup scripts

In the `setup/` folder there arre scripts:

- `setup_ardupilot_env.sh` – sets up the **ArduPilot build/runtime environment**:
  - clones/updates `~/ardupilot`
  - installs ArduPilot prerequisites
  - adds `ardupilot/Tools/autotest` and `ccache` to your `PATH`
- `setup_ardupilot_gz.sh` – sets up **Gazebo + ardupilot_gazebo**:
  - installs Gazebo Harmonic dependencies
  - clones/updates `~/ardupilot_gazebo` and builds it
  - configures `GZ_SIM_SYSTEM_PLUGIN_PATH` and `GZ_SIM_RESOURCE_PATH` in `~/.bashrc`

Run both once (from this repo):

```bash
chmod +x setup/setup_ardupilot_env.sh setup/setup_ardupilot_gz.sh
./setup/setup_ardupilot_env.sh
./setup/setup_ardupilot_gz.sh
```

Then open a **new terminal** so the environment changes take effect.

### Run the simulation

![Default simulation](doc/default_sim.png)

1. **Start Gazebo** (terminal 1):

```bash
gz sim -v4 -r iris_runway.sdf
```

2. **Start ArduPilot SITL** (terminal 2):

```bash
cd ~/ardupilot     # adjust if needed
sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --map --console
```

3. **Arm and take off** in the MAVProxy console:

```text
STABILIZE> mode guided
GUIDED> arm throttle
GUIDED> takeoff 5
```
