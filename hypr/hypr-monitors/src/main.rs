use anyhow::{anyhow, Result};
use hyprland::data::Monitors;
use hyprland::event_listener::EventListener;
use hyprland::keyword::*;
use hyprland::prelude::*;
use std::collections::HashSet;
use std::io::Read;
use std::os::unix::net::UnixStream;
use std::process::ExitCode;
use std::str::FromStr;
use std::thread;
use tracing::warn;
use tracing::{debug, error, info, trace};
use tracing_panic::panic_hook;
use tracing_subscriber::fmt::time::LocalTime;
use tracing_subscriber::prelude::__tracing_subscriber_SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::{fmt, Registry};

#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
enum MonitorIdentifier {
    Description(&'static str),
    /// e.g. "eDP-1"
    Port(&'static str),
    /// automatically assigned by hyprland incrementally
    Id(u32),
}

impl MonitorIdentifier {
    fn to_hyprland_id(&self) -> String {
        match self {
            MonitorIdentifier::Description(d) => format!("desc:{d}"),
            MonitorIdentifier::Port(p) => format!("{p}"),
            MonitorIdentifier::Id(n) => format!("id:{n}"),
        }
    }
}

/// Monitors that are known to be connected to my laptop.
#[derive(Debug, Clone, Hash, PartialEq, Eq, PartialOrd, Ord)]
struct KnownMonitor {
    identifier: MonitorIdentifier,
    width: u32,
    height: u32,
}

const LAPTOP_DISPLAY: KnownMonitor = KnownMonitor {
    identifier: MonitorIdentifier::Port("eDP-1"),
    width: 1920,
    height: 1200,
};
const HOME_MONITOR: KnownMonitor = KnownMonitor {
    // identifier: MonitorIdentifier::Description("Viewteck Co. Ltd. GFT27DB 0x00000001"),
    // identifier: MonitorIdentifier::Port("DP-5"),
    identifier: MonitorIdentifier::Id(1),
    width: 2560,
    height: 1440,
};
const APT_MONITOR: KnownMonitor = KnownMonitor {
    // identifier: MonitorIdentifier::Description("Viewteck Co. Ltd. GFT27DB 0x00000001"),
    identifier: MonitorIdentifier::Id(2),
    ..HOME_MONITOR
};
const KNOWN_MONITORS: &[KnownMonitor] = &[LAPTOP_DISPLAY, HOME_MONITOR, APT_MONITOR];

#[derive(Debug)]
struct MonitorLayout(Option<Dock>, LidState);

/// The docks to which my laptop may be connected.
#[derive(Debug)]
enum Dock {
    Apt,
    Home,
}

/// The state of the laptop lid.
#[derive(Debug)]
enum LidState {
    Open,
    Closed,
}
impl LidState {
    fn is_open(&self) -> bool {
        match self {
            LidState::Open => true,
            LidState::Closed => false,
        }
    }
}

impl TryFrom<(hyprland::data::Monitors, LidState)> for MonitorLayout {
    type Error = anyhow::Error;

    fn try_from((monitors, lid): (Monitors, LidState)) -> std::result::Result<Self, Self::Error> {
        // detect the dock based on the connected monitors
        let connected_now = monitors.to_vec();
        let dock: Option<Dock> = {
            // check if the known monitors are connected
            let connected_known: HashSet<&KnownMonitor> = connected_now
                .iter()
                .filter_map(|m| {
                    KNOWN_MONITORS.iter().find(|known| match known.identifier {
                        MonitorIdentifier::Description(d) => d == m.description.as_str(),
                        MonitorIdentifier::Port(p) => p == m.name.as_str(),
                        MonitorIdentifier::Id(n) => m.id as u32 == n,
                    })
                })
                .collect();
            // map connected monitors to docks
            if connected_known.contains(&HOME_MONITOR) && connected_known.contains(&APT_MONITOR) {
                Some(Dock::Home)
            } else if connected_known.contains(&APT_MONITOR) {
                Some(Dock::Apt)
            } else if connected_known.contains(&LAPTOP_DISPLAY) && connected_now.len() == 1 {
                None
            } else {
                return Err(anyhow!("Unknown monitor layout: {:?}", connected_now));
            }
        };
        Ok(Self(dock, lid))
    }
}

fn update_layout() -> Result<()> {
    let monitors = Monitors::get()?;
    let lid_closed = poll_lid()?;
    let layout = MonitorLayout::try_from((monitors, lid_closed))?;
    debug!("Transitioning to layout: {:?}", layout);
    match layout {
        // test manually with `hyprctl keyword monitor _`
        MonitorLayout(None, _) => {
            let config = "eDP-1,preferred,auto,1";
            Keyword::set("monitor", config)?;
        }
        MonitorLayout(Some(Dock::Apt), LidState::Open) => {
            let laptop_scale = 1.0;
            let laptop_config = format!(
                "{},{}x{},0x0,{laptop_scale}",
                LAPTOP_DISPLAY.identifier.to_hyprland_id(),
                LAPTOP_DISPLAY.width,
                LAPTOP_DISPLAY.height,
            );
            let laptop_display_width = LAPTOP_DISPLAY.width as f64 * (1.0 / laptop_scale);
            let external_config = format!(
                "{},preferred,{}x0,1",
                APT_MONITOR.identifier.to_hyprland_id(),
                f64::floor(laptop_display_width)
            );
            Keyword::set("monitor", laptop_config)?;
            Keyword::set("monitor", external_config)?;
        }
        MonitorLayout(Some(Dock::Home), LidState::Open) => {
            let laptop_scale = 1.0;
            let laptop_config = format!(
                "{},{}x{},0x0,{laptop_scale}",
                LAPTOP_DISPLAY.identifier.to_hyprland_id(),
                LAPTOP_DISPLAY.width,
                LAPTOP_DISPLAY.height,
            );
            let laptop_display_width = LAPTOP_DISPLAY.width as f64 * (1.0 / laptop_scale);
            let external1_config = format!(
                "{},preferred,{}x0,1",
                HOME_MONITOR.identifier.to_hyprland_id(),
                f64::floor(laptop_display_width)
            );
            let external2_config = format!(
                "{},preferred,{}x0,1",
                APT_MONITOR.identifier.to_hyprland_id(),
                f64::floor(laptop_display_width) + HOME_MONITOR.width as f64
            );
            Keyword::set("monitor", laptop_config)?;
            Keyword::set("monitor", external1_config)?;
            Keyword::set("monitor", external2_config)?;
        }
        MonitorLayout(_, LidState::Closed) => {
            Keyword::set("monitor", "eDP-1,disabled")?;
        }
    }
    Ok(())
}

fn main() -> ExitCode {
    // init logging
    let std_subscriber = fmt::layer().with_timer(LocalTime::rfc_3339());
    let combined_subscriber = Registry::default().with(std_subscriber);
    combined_subscriber.try_init().unwrap(); // set as global default
    std::panic::set_hook(Box::new(panic_hook));
    info!("Started hypr-monitors");

    let mut event_listener = EventListener::new();
    event_listener.add_monitor_added_handler(|_| {
        let res = update_layout();
        if let Err(e) = res {
            warn!("Failed to update layout: {:?}", e);
        }
    });
    event_listener.add_monitor_removed_handler(|_| {
        let res = update_layout();
        if let Err(e) = res {
            warn!("Failed to update layout: {:?}", e);
        }
    });
    let lid_handle = thread::spawn(|| {
        let res = listen_acpid(|e| match e {
            AcpidEvent::LidEvent(_) => update_layout().unwrap_or_else(|e| {
                warn!("Failed to update layout: {:?}", e);
                ()
            }),
        });
        if let Err(e) = res {
            error!("Failed to listen to acpid: {:?}", e);
            // TODO: exit the program
        }
    });
    let initial_res = update_layout();
    if let Err(e) = initial_res {
        // initial layout (i.e. if booting with lid closed then turn off laptop display)
        warn!("Failed to update initial layout: {:?}", e);
    }
    if let Err(e) = event_listener.start_listener() {
        error!("Failed to start hyprland event listener: {:?}", e);
        return ExitCode::FAILURE;
    }
    lid_handle.join().unwrap();
    ExitCode::SUCCESS
}

#[derive(Debug)]
enum AcpidEvent {
    LidEvent(LidState),
}

impl FromStr for AcpidEvent {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        let parsed = match s {
            "button/lid LID close" => Some(AcpidEvent::LidEvent(LidState::Closed)),
            "button/lid LID open" => Some(AcpidEvent::LidEvent(LidState::Open)),
            _ => None,
        };
        parsed.ok_or(anyhow!("Unknown acpid event: {}", s))
    }
}

/// Connect to the acpid socket and listen for system events, blocking the calling thread.
///
/// Ensure that the acpid service is running before calling this.
fn listen_acpid(f: impl Fn(AcpidEvent)) -> Result<()> {
    let mut sock =
        UnixStream::connect("/var/run/acpid.socket").expect("failed to connect to socket");
    loop {
        let mut buf = [0; 1024];
        let n = sock.read(&mut buf).expect("failed to read from socket");
        let data = std::str::from_utf8(&buf[..n]).unwrap().trim_end();
        match data.parse::<AcpidEvent>() {
            Ok(event) => {
                trace!("Parsed ACPID event: {:?}", event);
                f(event)
            }
            Err(e) => trace!("Ignored ACPID event: {:?}", e),
        }
    }
}

fn poll_lid() -> Result<LidState> {
    let mut file = std::fs::File::open("/proc/acpi/button/lid/LID0/state")?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    if contents.contains("open") {
        Ok(LidState::Open)
    } else if contents.contains("closed") {
        Ok(LidState::Closed)
    } else {
        Err(anyhow!("Unknown lid state: {}", contents))
    }
}
