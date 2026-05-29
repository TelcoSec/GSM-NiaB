from flask import Flask, render_template, request, flash, jsonify, Response,  url_for # type: ignore
import psutil
import subprocess
import telnetlib
import time
import sqlite3


app = Flask(__name__,
            static_url_path='', 
            static_folder='static/')

app.secret_key = 'your_secret_key'


# Define the services you want to control
services = {
    "osmo-msc": {"name": "Osmo MSC", "status": "unknown"},
    "osmo-hlr": {"name": "Osmo HLR", "status": "unknown"},
    "osmo-bsc": {"name": "Osmo BSC", "status": "unknown"},
    "asterisk": {"name": "Asterisk", "status": "unknown"},
}

def get_service_status(service_name):
  try:
    process = subprocess.run(["systemctl", "is-active", service_name], capture_output=True)
    if process.returncode == 0:
      return "active"
    else:
      return "inactive"
  except FileNotFoundError:
    return "unknown"

# Update initial service statuses
for service_name in services:
  services[service_name]["status"] = get_service_status(service_name)

@app.route("/")
def index():
  """
  Renders the dashboard with the current service statuses.
  """
  return render_template("index.html", services=services)

@app.route("/control/<service_name>/<action>")
def control_service(service_name, action):
  """
  Handles service control actions (start, stop, restart).

  Args:
    service_name: The name of the service.
    action: The action to perform (start, stop, restart).
  """
  if service_name in services:
    try:
      if action == "start":
        subprocess.run(["sudo", "systemctl", "start", service_name])
      elif action == "stop":
        subprocess.run(["sudo", "systemctl", "stop", service_name])
      elif action == "enable":
        subprocess.run(["sudo", "systemctl", "enable", service_name])
      elif action == "disable":
        subprocess.run(["sudo", "systemctl", "disable", service_name])
      elif action == "restart":
        subprocess.run(["sudo", "systemctl", "restart", service_name])
      services[service_name]["status"] = get_service_status(service_name)
    except Exception as e:
      print(f"Error controlling service: {e}")
  return render_template("index.html", services=services)

@app.route("/repos", methods=["GET", "POST"])
def repos():
    """
    Renders the system repositories configuration page and handles file saving.
    """
    if request.method == "get":
        try:
            # Get the submitted repo file content
            repo_content = request.form.get("repo_content")

            # Save the content to the sources.list file (requires sudo)
            with open("/tmp/sources.list", "w") as f:
                f.write(repo_content)
            subprocess.run(["sudo", "cp", "/tmp/sources.list", "/etc/apt/sources.list"])
            subprocess.run(["sudo", "apt", "update"])  # Update package list

            flash("Repositories file updated successfully!", "success")
        except Exception as e:
            flash(f"Error updating repositories file: {e}", "danger")

    # Read the current content of the sources.list file
    try:
        with open("/etc/apt/sources.list", "r") as f:
            current_content = f.read()
    except FileNotFoundError:
        current_content = "# Repositories file not found."

    return render_template("repos.html", current_content=current_content,services=services)



@app.route('/osmohlr', methods=['GET', 'POST'])
def hlr_manager():
    """
    Manage and monitor the OsmoHLR server.
    """
    status = ""
    config = ""
    if request.method == 'POST':
        if 'action' in request.form:
            action = request.form['action']
            try:
                if action == 'start':
                    subprocess.check_output(['sudo', 'systemctl', 'start', 'osmo-hlr'])
                    status = "OsmoMSC server started successfully."
                elif action == 'stop':
                    subprocess.check_output(['sudo', 'systemctl', 'stop', 'osmo-hlr'])
                    status = "OsmoMSC server stopped successfully."
                elif action == 'restart':
                    subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-hlr'])
                    status = "OsmoMSC server restarted successfully."
                elif action == 'status':
                    output = subprocess.check_output(['sudo', 'systemctl', 'status', 'osmo-hlr'])
                    status = output.decode()
            except subprocess.CalledProcessError as e:
                status = f"Error: {e.output.decode()}"
        elif 'config' in request.form:
            config = request.form['config']
            try:
                with open('/etc/osmocom/osmo-hlr.cfg', 'w') as f:
                    f.write(config)
                subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-hlr'])
                status = "sshd_config updated successfully."
            except Exception as e:
                status = f"Error: {e}"
    else:
        try:
            with open('/etc/osmocom/osmo-hlr.cfg', 'r') as f:
                config = f.read()
        except Exception as e:
            status = f"Error reading osmo-hlr.cfg: {e}"

    return render_template('osmohlr.html', status=status, config=config)

@app.route('/osmomsc', methods=['GET', 'POST'])
def msc_manager():
    """
    Manage and monitor the OsmoMSC server.
    """
    status = ""
    config = ""
    if request.method == 'POST':
        if 'action' in request.form:
            action = request.form['action']
            try:
                if action == 'start':
                    subprocess.check_output(['sudo', 'systemctl', 'start', 'osmo-msc'])
                    status = "OsmoMSC server started successfully."
                elif action == 'stop':
                    subprocess.check_output(['sudo', 'systemctl', 'stop', 'osmo-msc'])
                    status = "OsmoMSC server stopped successfully."
                elif action == 'restart':
                    subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-msc'])
                    status = "OsmoMSC server restarted successfully."
                elif action == 'status':
                    output = subprocess.check_output(['sudo', 'systemctl', 'status', 'osmo-msc'])
                    status = output.decode()
            except subprocess.CalledProcessError as e:
                status = f"Error: {e.output.decode()}"
        elif 'config' in request.form:
            config = request.form['config']
            try:
                with open('/etc/osmocom/osmo-msc.cfg', 'w') as f:
                    f.write(config)
                subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-msc'])
                status = "sshd_config updated successfully."
            except Exception as e:
                status = f"Error: {e}"
    else:
        try:
            with open('/etc/osmocom/osmo-msc.cfg', 'r') as f:
                config = f.read()
        except Exception as e:
            status = f"Error reading osmo-msc.cfg: {e}"

    return render_template('osmomsc.html', status=status, config=config)


@app.route('/osmobsc', methods=['GET', 'POST'])
def bsc_manager():
    """
    Manage and monitor the OsmoBSC server.
    """
    status = ""
    config = ""
    if request.method == 'POST':
        if 'action' in request.form:
            action = request.form['action']
            try:
                if action == 'start':
                    subprocess.check_output(['sudo', 'systemctl', 'start', 'osmo-msc'])
                    status = "OsmoMSC server started successfully."
                elif action == 'stop':
                    subprocess.check_output(['sudo', 'systemctl', 'stop', 'osmo-msc'])
                    status = "OsmoMSC server stopped successfully."
                elif action == 'restart':
                    subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-msc'])
                    status = "OsmoMSC server restarted successfully."
                elif action == 'status':
                    output = subprocess.check_output(['sudo', 'systemctl', 'status', 'osmo-msc'])
                    status = output.decode()
            except subprocess.CalledProcessError as e:
                status = f"Error: {e.output.decode()}"
        elif 'config' in request.form:
            config = request.form['config']
            try:
                with open('/etc/osmocom/osmo-msc.cfg', 'w') as f:
                    f.write(config)
                subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-msc'])
                status = "sshd_config updated successfully."
            except Exception as e:
                status = f"Error: {e}"
    else:
        try:
            with open('/etc/osmocom/osmo-hlr.cfg', 'r') as f:
                config = f.read()
        except Exception as e:
            status = f"Error reading osmo-hlr.cfg: {e}"

    return render_template('osmomsc.html', status=status, config=config)


### BTS Route
@app.route('/osmobts', methods=['GET', 'POST'])
def bts_manager():
    """
    Manage and monitor the OsmoBSC server.
    """
    status = ""
    config = ""
    if request.method == 'POST':
        if 'action' in request.form:
            action = request.form['action']
            try:
                if action == 'start':
                    subprocess.check_output(['sudo', 'systemctl', 'start', 'osmo-bts'])
                    status = "OsmoBTS server started successfully."
                elif action == 'stop':
                    subprocess.check_output(['sudo', 'systemctl', 'stop', 'osmo-bts'])
                    status = "OsmoBTS server stopped successfully."
                elif action == 'restart':
                    subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-bts'])
                    status = "OsmoBTS server restarted successfully."
                elif action == 'status':
                    output = subprocess.check_output(['sudo', 'systemctl', 'status', 'osmo-bts'])
                    status = output.decode()
            except subprocess.CalledProcessError as e:
                status = f"Error: {e.output.decode()}"
        elif 'config' in request.form:
            config = request.form['config']
            try:
                with open('/etc/osmocom/osmo-bts.cfg', 'w') as f:
                    f.write(config)
                subprocess.check_output(['sudo', 'systemctl', 'restart', 'osmo-bts'])
                status = "sshd_config updated successfully."
            except Exception as e:
                status = f"Error: {e}"
    else:
        try:
            with open('/etc/osmocom/osmo-hlr.cfg', 'r') as f:
                config = f.read()
        except Exception as e:
            status = f"Error reading osmo-hlr.cfg: {e}"

    return render_template('osmobts.html', status=status, config=config)

@app.route('/grgsm', methods=['GET', 'POST'])
def grgsm_tool():
    """
    Interact with the grgsm tool.
    """
    output = ""
    command = ""
    if request.method == 'POST':
        action = request.form['action']
        args = request.form.get('args', '')  # Get additional arguments

        # Basic input validation to prevent arbitrary command execution
        allowed_actions = ['scan', 'info', 'capture', 'decode']
        if action not in allowed_actions:
            output = "Invalid action."
        else:
            command = f"/usr/bin/osmo-stp" # {action} {args}"
            try:
                # Execute the grgsm command and capture the output
                process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout, stderr = process.communicate()
                output = stdout.decode() + stderr.decode()
            except subprocess.CalledProcessError as e:
                output = f"Error executing grgsm: {e}"

    return render_template('grgsm.html', output=output, command=command)

@app.route('/config_editor')
def config_editor():
    """
    Edit tabbed configuration files.
    """
    files = {
        "OsmoHLR": "/etc/osmocom/osmo-hlr.cfg",
        "OsmoMSC": "/etc/osmocom/osmo-msc.cfg",
        "OsmoBSC": "/etc//etc/osmocom/osmo-bsc.cfg",
    }
    file_contents = {}
    for filename, filepath in files.items():
        try:
            with open(filepath, 'r') as f:
                file_contents[filename] = f.read()
        except Exception as e:
            file_contents[filename] = f"Error reading {filename}: {e}"

    return render_template('config_editor.html', files=file_contents)


@app.route('/drivers')
def drivers():
    """
    Edit tabbed configuration files.
    """
    files = {
        "LimeSDR": "/etc/osmocom/osmo-hlr.cfg",
        "BladeRF": "/etc/osmocom/osmo-msc.cfg",
        "Ettus": "/etc//etc/osmocom/osmo-bsc.cfg",
    }
    file_contents = {}
    for filename, filepath in files.items():
        try:
            with open(filepath, 'r') as f:
                file_contents[filename] = f.read()
        except Exception as e:
            file_contents[filename] = f"Error reading {filename}: {e}"

    return render_template('drivers.html', files=file_contents)



@app.route('/arfcn', methods=['GET', 'POST'])
def arfcn_calculator():
    """
    Calculate GSM ARFCN frequencies.
    """
    result = None
    if request.method == 'POST':
        try:
            arfcn = int(request.form['arfcn'])
            result = calculate_arfcn(arfcn)
        except ValueError:
            result = "Invalid input"
    return render_template('arfcn.html', result=result)

def calculate_arfcn(arfcn):
    """
    Calculate GSM ARFCN frequencies.
    """
    if 0 <= arfcn <= 124:
        uplink = 890 + 0.2 * arfcn
        downlink = uplink + 45
    elif 128 <= arfcn <= 251:
        uplink = 890 + 0.2 * (arfcn - 128)
        downlink = uplink + 45
    elif 512 <= arfcn <= 885:
        uplink = 935 + 0.2 * (arfcn - 512)
        downlink = uplink + 45
    else:
        return "Invalid ARFCN"
    return f"Uplink: {uplink} MHz, Downlink: {downlink} MHz"

@app.route('/telnet', methods=['GET', 'POST'])
def telnet_client():
    """
    Connect to a telnet server and execute commands.
    """
    output = ""
    host = ""
    port = 23  # Default telnet port
    if request.method == 'POST':
        host = request.form['host']
        try:
            port = int(request.form['port'])
        except ValueError:
            output = "Invalid port number."
        command = request.form['command']

        try:
            # Connect to the telnet server
            tn = telnetlib.Telnet(host, port)
            time.sleep(1)  # Allow some time for connection

            # Execute the command
            tn.write(command.encode('ascii') + b"\n")
            time.sleep(1)  # Allow some time for output

            # Read the output
            output = tn.read_very_eager().decode('ascii')
            tn.close()
        except Exception as e:
            output = f"Error connecting to telnet server: {e}"

    return render_template('telnet.html', output=output, host=host, port=port)

@app.route('/system_stats')
def system_stats():
    """
    Return system stats as JSON.
    """
    cpu = psutil.cpu_percent()
    mem = psutil.virtual_memory().percent
    disk = psutil.disk_usage('/').percent
    return jsonify(cpu=cpu, mem=mem, disk=disk)




@app.route('/sqlite_data')
def sqlite_data():
    """
    Read data from a SQLite3 database and display it.
    """
    data = []
    try:
        # Connect to the database
        conn = sqlite3.connect('/var/lib/osmocom/hlr.db')  # Replace with your database file
        cursor = conn.cursor()

        # Execute a SELECT query
        cursor.execute("SELECT * from subscriber")  # Replace with your table name

        # Fetch all results
        rows = cursor.fetchall()

        # Format data for display (optional)
        for row in rows:
            data.append(row)  # You can customize how you format the data

        # Close the connection
        conn.close()

    except Exception as e:
        return f"Error reading data from database: {e}"

    return render_template('sqlite_data.html', data=data)

@app.route('/services_monitor')
def services_monitor():
    services = ['osmo-bsc', 'osmo-msc', 'osmo-hlr']  # Example services
    return render_template('services_monitor.html', services=services)

@app.route('/service_status/<service_name>')
def service_status(service_name):
    """
    Return the status of a service.
    """
    try:
        output = subprocess.check_output(['systemctl', 'is-active', service_name])
        status = output.decode().strip()  # 'active' or 'inactive'
    except subprocess.CalledProcessError:
        status = 'unknown'
    return status


@app.route("/asterisk", methods=["GET", "POST"])
def asterisk():
    """
    Renders the Asterisk configuration page and handles configuration changes.
    """
    sip_conf_content = ""
    rtp_conf_content = ""
    extensions_conf_content = ""

    if request.method == "POST":
        try:
            # Get submitted configuration values
            bindaddr = request.form.get("bindaddr")
            sip_port = request.form.get("sip_port")
            rtp_start = request.form.get("rtp_start")
            rtp_end = request.form.get("rtp_end")
            extensions_conf_content = request.form.get("extensions_conf_content")

            # Update sip.conf
            with open("/tmp/sip.conf", "w") as f:
                f.write(f"udpbindaddr={bindaddr}\n")
                f.write(f"tcpenable=no\n")
                f.write(f"transport=udp\n")
                f.write(f"port={sip_port}\n")
            subprocess.run(["sudo", "cp", "/tmp/sip.conf", "/etc/asterisk/sip.conf"])

            # Update rtp.conf
            with open("/tmp/rtp.conf", "w") as f:
                f.write(f"rtpstart={rtp_start}\n")
                f.write(f"rtpend={rtp_end}\n")
            subprocess.run(["sudo", "cp", "/tmp/rtp.conf", "/etc/asterisk/rtp.conf"])

            # Update extensions.conf
            with open("/tmp/extensions.conf", "w") as f:
                f.write(extensions_conf_content)
            subprocess.run(["sudo", "cp", "/tmp/extensions.conf", "/etc/asterisk/extensions.conf"])

            # Reload Asterisk
            subprocess.run(["sudo", "asterisk", "-rx", "reload"])

            flash("Asterisk configuration updated successfully!", "success")
        except Exception as e:
            flash(f"Error updating Asterisk configuration: {e}", "danger")

    # Read current configuration values
    try:
        with open("/etc/asterisk/sip.conf", "r") as f:
            sip_conf_content = f.read()
        with open("/etc/asterisk/rtp.conf", "r") as f:
            rtp_conf_content = f.read()
        with open("/etc/asterisk/extensions.conf", "r") as f:
            extensions_conf_content = f.read()

        # Extract values (you might need to parse the files)
        # ...
    except FileNotFoundError:
        sip_conf_content = "# sip.conf not found."
        rtp_conf_content = "# rtp.conf not found."
        extensions_conf_content = "# extensions.conf not found."

    return render_template("asterisk.html", sip_conf_content=sip_conf_content,
                           rtp_conf_content=rtp_conf_content,
                           extensions_conf_content=extensions_conf_content)


def get_systemd_services():
    """
    Gets the status of systemd services.

    Returns:
        A list of dictionaries, where each dictionary represents a service
        with its name and status.
    """
    try:
        process = subprocess.run(["systemctl", "list-units", "--type=service", "--no-pager",
                                 "--no-legend", "--all"], capture_output=True, text=True)
        services = []
        for line in process.stdout.splitlines():
            parts = line.split()
            if len(parts) >= 5:
                service = {
                    "name": parts[0].strip(),
                    "status": parts[3].strip()
                }
                services.append(service)
        return services
    except FileNotFoundError:
        return []

def get_network_stats():
    """
    Gets network statistics.

    Returns:
        A dictionary with network stats (bytes sent, bytes received, etc.).
    """
    net_io = psutil.net_io_counters()
    return {
        "bytes_sent": net_io.bytes_sent,
        "bytes_recv": net_io.bytes_recv,
        # ... add other network stats as needed
    }

def get_cpu_usage():
    """
    Gets CPU usage.

    Returns:
        The overall CPU usage percentage.
    """
    return psutil.cpu_percent(interval=1)

def get_ram_usage():
    """
    Gets RAM usage.

    Returns:
        A dictionary with RAM stats (total, used, available).
    """
    mem = psutil.virtual_memory()
    return {
        "total": mem.total,
        "used": mem.used,
        "available": mem.available
    }

def get_disk_usage():
    """
    Gets disk usage.

    Returns:
        A dictionary with disk stats (total, used, free).
    """
    disk = psutil.disk_usage('/')
    return {
        "total": disk.total,
        "used": disk.used,
        "free": disk.free
    }

def get_osmo_msc_status():
    """
    Gets the status of Osmocom MSC services.

    Returns:
        A list of dictionaries, where each dictionary represents an Osmocom MSC
        service with its name and status.
    """
    try:
        # Assuming you use systemctl to manage Osmocom MSC services
        process = subprocess.run(["systemctl", "list-units", "--type=service", "--no-pager",
                                 "--no-legend", "--all", "*osmo-msc*"], 
                                capture_output=True, text=True)
        services = []
        for line in process.stdout.splitlines():
            parts = line.split()
            if len(parts) >= 5:
                service = {
                    "name": parts[0].strip(),
                    "status": parts[3].strip()
                }
                services.append(service)
        return services
    except FileNotFoundError:
        return []



@app.route("/data")
def data():
    """Generates data for the dashboard in real-time."""
    def generate_data():
        while True:
            services = get_systemd_services()
            network = get_network_stats()
            osmo_msc_services = get_osmo_msc_status()
            cpu = get_cpu_usage()
            ram = get_ram_usage()
            disk = get_disk_usage()
            data = {
                "services": services,
                "osmo_msc_services": osmo_msc_services,
                "network": network,
                "cpu": cpu,
                "ram": ram,
                "disk": disk
            }
            yield f"data:{data}\n\n"
            time.sleep(2)  # Update every 2 seconds

    return Response(generate_data(), mimetype="text/event-stream")


if __name__ == "__main__":
    app.run(debug=True)
