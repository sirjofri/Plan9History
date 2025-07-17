# Plan 9 History Timeline

This is a collection of the Plan 9 history and a script to build an interactive SVG timeline.

## Adding History

The `history.txt` file is used as a database file.
It's field separator is a single tab character.

It contains the following fields:

- **Project**: The project identifier. Uppercase, and unique.
- **Year**: The year. Only numbers are allowed. This is used to place the entries.
- **Date**: Additional date information. Can be a clear date (`May 4`), a month (`May`) or a rough detail (`Summer`).
- **Event**: The event. Keep this short so it doesn't overlap other events.
- **Info**: Extended information about this event. This can be a bit longer.

## Building History

The repo contains two separate scripts:

- `build.sh`: This is a posix shell script that runs the compilation script.
- `script.awk`: This is an awk script that generates the svg file.

Requirements are common posix tools: a shell, sort, awk.

## Using History

- Open the `output.svg` file in a browser that is capable of viewing SVG files, including javascript.
- Interactive elements are highlighted, you can click on them.
- The svg should work without javascript, but then there will be no interaction.

## Contributing History

Many projects lack detailed information. Please add details if you know them.