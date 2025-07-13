# Jumperless-App
An app to talk to your Jumperless V5

## Make
GNU make can be used to manage the python virtual environment and build process.
i.e. `make package` will run JumperlessAppPackager.py after building a virtual environment
with all proper dependencies installed.

## Packager pip Versions
Specific package versions are stipulated in `Packager/constraints.txt`.
This keeps `Packager/packagerRequirements.txt` a little cleaner and allows for easier updating of versions.
To update package versions, just run `make Packager/constraints.txt`
