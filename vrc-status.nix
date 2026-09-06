{ pkgs, ... }:

let
  vrcStatusScript = pkgs.writers.writePython3Bin "vrc-status" {
    libraries = [
      pkgs.python3Packages.python-osc
      pkgs.python3Packages.dbus-python
    ];
  } ''
    import time
    import threading
    import dbus
    from pythonosc import udp_client

    # --- Config ---
    client = udp_client.SimpleUDPClient("127.0.0.1", 9000)
    bus = dbus.SessionBus()

    # State dictionary
    state = {"text": "", "music_enabled": True}


    def get_music_info():
        try:
            for service in bus.list_names():
                if service.startswith("org.mpris.MediaPlayer2."):
                    path = "/org/mpris/MediaPlayer2"
                    iface_name = "org.freedesktop.DBus.Properties"
                    player = bus.get_object(service, path)
                    iface = dbus.Interface(player, iface_name)
                    metadata = iface.Get(
                        "org.mpris.MediaPlayer2.Player", "Metadata"
                    )

                    title = str(metadata.get("xesam:title", ""))
                    artists = metadata.get("xesam:artist", [])

                    # Clean up list to string: "Artist1, Artist2"
                    artist_str = ", ".join([str(a) for a in artists])

                    if title:
                        if artist_str:
                            return f"🎵 {title} - {artist_str}"
                        return f"🎵 {title}"
        except Exception:
            pass
        return ""


    def send_loop():
        """Background loop that refreshes the chatbox every 30s"""
        while True:
            music = ""
            if state["music_enabled"]:
                music = get_music_info()

            manual = state["text"]

            if manual and music:
                full_msg = f"{manual} | {music}"
            elif manual:
                full_msg = manual
            elif music:
                full_msg = music
            else:
                full_msg = ""

            client.send_message("/chatbox/input", [full_msg, True, False])
            time.sleep(30)


    # Start background thread
    thread = threading.Thread(target=send_loop, daemon=True)
    thread.start()

    print("--- VRChat Status Controller ---")
    print("COMMANDS:")
    print("  :toggle  -> Turn music display ON/OFF")
    print("  <text>   -> Set status text")
    print("  <enter>  -> Clear status text")
    print("--------------------------------")

    while True:
        try:
            raw_input = input("Update Status: ")
            user_input = raw_input.strip()

            if user_input == ":toggle":
                state["music_enabled"] = not state["music_enabled"]
                mode = "ON" if state["music_enabled"] else "OFF"
                print(f"Music Display is now: {mode}")
                manual = state["text"]
            else:
                state["text"] = user_input
                manual = user_input

            music = ""
            if state["music_enabled"]:
                music = get_music_info()

            if manual and music:
                display = f"{manual} | {music}"
            else:
                display = manual or music

            client.send_message("/chatbox/input", [display, True, False])
            print(f"Sent: '{display}'" if display else "Cleared.")
        except EOFError:
            break
  '';
in
{
  home.packages = [ vrcStatusScript ];
}

