-- Receives fleet:// URLs (opened by the OmniShell fleet widget) and hands
-- them to bin/fleet-url, which validates and runs `fleet notification-open`.
-- Built + registered by `./install.sh fleet-url-handler`; not committed as an app.
on open location theURL
	do shell script quoted form of (POSIX path of (path to home folder) & "bin/fleet-url") & " " & quoted form of theURL
end open location
