import QtQuick 2.3
import SAMBA 3.1

/*! \internal */
Applet {
	name: "sdmmc"
	description: "SD/MMC"
	codeUrl: Qt.resolvedUrl("applets/applet-sdmmc_sama5d2-generic_sram.bin")
	codeAddr: 0x220000
	mailboxAddr: 0x220004
	commands: [
		AppletCommand { name:"initialize"; code:0; timeout: 1000 },
		AppletCommand { name:"readPages"; code:0x32 },
		AppletCommand { name:"writePages"; code:0x33; timeout: 1000 }
	]

	/*! \internal */
	function buildInitArgs(connection, device) {
		if (typeof device.config.sdmmcInstance === "undefined")
			throw new Error("Incomplete configuration, missing value for sdmmcInstance")

		if (typeof device.config.sdmmcPartition === "undefined")
			throw new Error("Incomplete configuration, missing value for sdmmcPartition")

		if (typeof device.config.sdmmcBusWidth === "undefined")
			throw new Error("Incomplete configuration, missing value for sdmmcBusWidth")

		if (typeof device.config.sdmmcVoltages === "undefined")
			throw new Error("Incomplete configuration, missing value for sdmmcVoltages")

		var args = defaultInitArgs(connection, device)
		var config = [ device.config.sdmmcInstance,
		               device.config.sdmmcPartition,
		               device.config.sdmmcBusWidth,
		               device.config.sdmmcVoltages ]
		Array.prototype.push.apply(args, config)
		return args
	}

	/* -------- Command Line Handling -------- */

	/*! \internal */
	function commandLineParse(device, args)	{
		switch (args.length)
		{
		case 4:
			if (args[3].length > 0) {
				device.config.sdmmcVoltages = Number(args[3]);
				if (isNaN(device.config.sdmmcVoltages))
					return "Invalid SD/MMC voltages (not a number)."
			}
			// fall-through
		case 3:
			if (args[2].length > 0) {
				device.config.sdmmcBusWidth = Number(args[2]);
				if (isNaN(device.config.sdmmcBusWidth))
					return "Invalid SD/MMC bus width (not a number)."
			}
			// fall-through
		case 2:
			if (args[1].length > 0) {
				device.config.sdmmcPartition = Number(args[1]);
				if (isNaN(device.config.sdmmcPartition))
					return "Invalid SD/MMC partition (not a number)."
			}
			// fall-through
		case 1:
			if (args[0].length > 0) {
				device.config.sdmmcInstance = Number(args[0]);
				if (isNaN(device.config.sdmmcInstance))
					return "Invalid SD/MMC instance (not a number)."
			}
			// fall-through
		case 0:
			return true;
		default:
			return "Invalid number of arguments."
		}
	}

	/*! \internal */
	function commandLineHelp() {
		return ["Syntax: sdmmc:[<instance>]:[<partition>]:[<bus_width>]:[<voltages>]",
		        "Parameters:",
		        "    instance   SDMMC controller number",
		        "    partition  Partition number (0=user partition, x>0=boot partition x)",
		        "    bus_width  Data bus width (0=controller max, 1=1-bit, 4=4-bit, 8=8-bit)",
		        "    voltages   Supported voltages (bitfield: 1=1.8V, 2=3.0V, 4=3.3V)",
		        "Examples:",
		        "    sdmmc          use default board settings",
		        "    sdmmc:0:1:8:5  use fully custom settings (SDMMC0, first boot partition, 8-bit, 1.8V/3.3V)",
		        "    sdmmc:0:1      use default board settings but force use of SDMMC0, first boot partition"]
	}
}