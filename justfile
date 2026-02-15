# Backup
drive_uuid := "77688511-78c5-4de3-9108-b631ff823ef4"
user :=  file_stem(home_dir())
def_drive := join("/media", user, drive_uuid, "env")

golocal := join(home_dir(), "gokrazy")
gokrazy := join(home_dir(), "gokrazy")

# list all recipes
default:
    just --list

# Add conveniente development dependencies
gok:
    go install github.com/gokrazy/tools/cmd/gok@main

# start afresh
anew:
    rm -fr {{gokrazy}}
    sudo rm -fr {{golocal}}

# Clears a gokrazy instance
clear instance:
    #!/usr/bin/env bash
    set -exuo pipefail
    rm -fr {{gokrazy}}/{{instance}}/config.json
    test -f {{gokrazy}}/{{instance}}/wifi.json && rm -f {{gokrazy}}/{{instance}}/wifi.json


gokrazy:
    #!/usr/bin/env bash
    set -exuo pipefail
    go install github.com/gokrazy/tools/cmd/gok@main

# Install gokraczy base system
base instance ssid passwd: (gokrazy)
    #!/usr/bin/env bash
    set -exuo pipefail
    go install github.com/gokrazy/tools/cmd/gok@main
    gok new -i {{instance}}
    sed -i '/"GOARCH=arm64"/s/$/,/' {{gokrazy}}/{{instance}}/config.json
    sed -i '/"GOARCH=arm64"/a\        "GOKRAZY_RPI=model-zero-2-w"' {{gokrazy}}/{{instance}}/config.json
    # Standard packages needed
    gok add -i {{instance}} github.com/gokrazy/wifi
    gok add -i {{instance}} github.com/gokrazy/mkfs
    sed -i '/"PackageConfig": {/a\
        "github.com/gokrazy/wifi": {\
            "ExtraFilePaths": {\
                "/etc/wifi.json": "wifi.json"\
            }\
        },' {{gokrazy}}/{{instance}}/config.json

    cat <<EOF > {{gokrazy}}/{{instance}}/wifi.json
    {
        "ssid": "{{ssid}}",
        "psk": "{{passwd}}"
    }
    EOF



# add reticulum packages
step instance pkg:
    #!/usr/bin/env bash
    set -exuo pipefail
    gok add -i {{instance}} github.com/svanichkin/go-reticulum/cmd/{{pkg}}
    sed -i '/"PackageConfig": {/a\
        "github.com/svanichkin/go-reticulum/cmd/{{pkg}}": {\
            "CommandLineFlags": [\
                "-config=/perm/.reticulum"\
            ]\
        },' {{gokrazy}}/{{instance}}/config.json

# add reticulum packages
reticulum instance: (step instance "rnsd")  (step instance "rnx") (step instance "rnpath") (step instance "rncp")  (step instance "rnir")

# the whole process
all instance ssid passwd: (base instance ssid passwd) (reticulum instance)
    #!/usr/bin/env bash
    set -exuo pipefail
    gok edit -i {{instance}}
    gok sbom -i {{instance}}

# Generate SD Contents with GoKrazy App
flash instance sdcard:
    gok overwrite -i {{instance}} --full {{sdcard}}

# Update a living GoCrazy instance
update instance:
    gok update -i {{instance}}
