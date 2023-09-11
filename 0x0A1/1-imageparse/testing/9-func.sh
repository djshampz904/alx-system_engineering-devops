#!/bin/bash

displayMemory()
{
	echo "Mem detail: "
	free -m
}

displayUptime()
{
	echo "Uptime details"
	uptime
}

displayCPUMemInfo()
{
	echo "CPU mem info"
	cat /proc/meminfo
}

displayMemory
displayUptime
displayCPUMemInfo
