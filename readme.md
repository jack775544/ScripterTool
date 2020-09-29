# Scripter Tool

Tool for parsing BZS files created by the Battlezone Scripter and converting them into lua that can be read by BZCC.

This project is a work in progress and not all commands that are supported by the Scripter can be converted into lua.

## Usage

```
cd ScripterTool.Cli
dotnet run input.bzs output.lua
```

## Examples

An example input file can be found [here](/Examples/FS01.bzs)

An example output file can be found [here](Examples/FS01.lua).