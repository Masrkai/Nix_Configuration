>>>>>>Hi Masrkai! ~
07:49:18[masrkai_NixOS]$ sudo sensors-detect --auto
# sensors-detect version 3.6.0
# System: Hewlett-Packard HP ZBook 14 G2 [A3009D510303] (laptop)
# Board: Hewlett-Packard 2216
# Kernel: 6.6.57 x86_64
# Processor: Intel(R) Core(TM) i7-5600U CPU @ 2.60GHz (6/61/4)

Running in automatic mode, default answers to all questions
are assumed.

Some south bridges, CPUs or memory controllers contain embedded sensors.
Do you want to scan for them? This is totally safe. (YES/no): 
Module cpuid loaded successfully.
Silicon Integrated Systems SIS5595...                       No
VIA VT82C686 Integrated Sensors...                          No
VIA VT8231 Integrated Sensors...                            No
AMD K8 thermal sensors...                                   No
AMD Family 10h thermal sensors...                           No
AMD Family 11h thermal sensors...                           No
AMD Family 12h and 14h thermal sensors...                   No
AMD Family 15h thermal sensors...                           No
AMD Family 16h thermal sensors...                           No
AMD Family 17h thermal sensors...                           No
AMD Family 15h power sensors...                             No
AMD Family 16h power sensors...                             No
Hygon Family 18h thermal sensors...                         No
Intel digital thermal sensor...                             Success!
    (driver `coretemp')
Intel AMB FB-DIMM thermal sensor...                         No
Intel 5500/5520/X58 thermal sensor...                       No
VIA C7 thermal sensor...                                    No
VIA Nano thermal sensor...                                  No

Some Super I/O chips contain embedded sensors. We have to write to
standard I/O ports to probe them. This is usually safe.
Do you want to scan for Super I/O sensors? (YES/no): 
Probing for Super-I/O at 0x2e/0x2f
Trying family `National Semiconductor/ITE'...               No
Trying family `SMSC'...                                     Yes
Found unknown chip with ID 0x15a0
Probing for Super-I/O at 0x4e/0x4f
Trying family `National Semiconductor/ITE'...               No
Trying family `SMSC'...                                     No
Trying family `VIA/Winbond/Nuvoton/Fintek'...               No
Trying family `ITE'...                                      No

Some hardware monitoring chips are accessible through the ISA I/O ports.
We have to write to arbitrary I/O ports to probe them. This is usually
safe though. Yes, you do have ISA I/O ports even if you do not have any
ISA slots! Do you want to scan the ISA I/O ports? (YES/no): 
Probing for `National Semiconductor LM78' at 0x290...       No
Probing for `National Semiconductor LM79' at 0x290...       No
Probing for `Winbond W83781D' at 0x290...                   No
Probing for `Winbond W83782D' at 0x290...                   No

Lastly, we can probe the I2C/SMBus adapters for connected hardware
monitoring devices. This is the most risky part, and while it works
reasonably well on most systems, it has been reported to cause trouble
on some systems.
Do you want to probe the I2C/SMBus adapters now? (YES/no): 
Using driver `i2c-i801' for device 0000:00:1f.3: Wildcat Point-LP (PCH)
Module i2c-dev loaded successfully.

Next adapter: AMDGPU i2c bit bus 0x90 (i2c-0)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x91 (i2c-1)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x92 (i2c-2)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x93 (i2c-3)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x94 (i2c-4)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x95 (i2c-5)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x96 (i2c-6)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AMDGPU i2c bit bus 0x97 (i2c-7)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: SMBus I801 adapter at ef80 (i2c-8)
Do you want to scan it? (YES/no/selectively): 
Client found at address 0x2c
Handled by driver `rmi_smbus' (already loaded), chip type `rmi4_smbus'
    (note: this is probably NOT a sensor chip!)
Client found at address 0x50
Handled by driver `at24' (already loaded), chip type `spd'
    (note: this is probably NOT a sensor chip!)
Client found at address 0x52
Probing for `Analog Devices ADM1033'...                     No
Probing for `Analog Devices ADM1034'...                     No
Probing for `SPD EEPROM'...                                 Yes
    (confidence 8, not a hardware monitoring chip)

Next adapter: i915 gmbus vga (i2c-9)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: i915 gmbus dpc (i2c-10)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: i915 gmbus dpb (i2c-11)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: i915 gmbus dpd (i2c-12)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AUX A/DDI A/PHY A (i2c-13)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AUX B/DDI B/PHY B (i2c-14)
Do you want to scan it? (yes/NO/selectively): 

Next adapter: AUX C/DDI C/PHY C (i2c-15)
Do you want to scan it? (yes/NO/selectively): 


Now follows a summary of the probes I have just done.

Driver `coretemp':
  * Chip `Intel digital thermal sensor' (confidence: 9)

Do you want to generate /etc/sysconfig/lm_sensors? (yes/NO): 
To load everything that is needed, add this to one of the system
initialization scripts (e.g. /etc/rc.d/rc.local):

#----cut here----
# Chip drivers
modprobe coretemp
/usr/local/bin/sensors -s
#----cut here----

You really should try these commands right now to make sure everything
is working properly. Monitoring programs won't work until the needed
modules are loaded.

Unloading i2c-dev... OK
Unloading cpuid... OK

>>>>>>Hi Masrkai! ~
07:50:49[masrkai_NixOS]$ sensors
amdgpu-pci-0300
Adapter: PCI adapter
fan1:             N/A
edge:             N/A  (crit = +120.0°C, hyst = +90.0°C)

coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +74.0°C  (high = +105.0°C, crit = +105.0°C)
Core 0:        +64.0°C  (high = +105.0°C, crit = +105.0°C)
Core 1:        +74.0°C  (high = +105.0°C, crit = +105.0°C)

BAT0-acpi-0
Adapter: ACPI interface
in0:          12.63 V  
curr1:         1.37 A  

acpitz-acpi-0
Adapter: ACPI interface
temp1:        +60.0°C  
temp2:         +0.0°C  
temp3:        +46.0°C  
temp4:        +52.0°C  
temp5:        +40.0°C  
temp6:         +0.0°C  

>>>>>>Hi Masrkai! ~
07:51:01[masrkai_NixOS]$ ls -l /sys/class/hwmon/
lrwxrwxrwx - root 24 Oct 07:50  hwmon0 -> ../../devices/pci0000:00/0000:00:1c.4/0000:03:00.0/hwmon/hwmon0
lrwxrwxrwx - root 24 Oct 07:50  hwmon1 -> ../../devices/virtual/thermal/thermal_zone0/hwmon1
lrwxrwxrwx - root 24 Oct 07:50  hwmon2 -> ../../devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0003:00/power_supply/AC/hwmon2
lrwxrwxrwx - root 24 Oct 07:50  hwmon3 -> ../../devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT0/hwmon3
lrwxrwxrwx - root 24 Oct 07:50  hwmon4 -> ../../devices/platform/hp-wmi/hwmon/hwmon4
lrwxrwxrwx - root 24 Oct 07:50  hwmon5 -> ../../devices/platform/coretemp.0/hwmon/hwmon5
>>>>>>Hi Masrkai! ~
07:51:19[masrkai_NixOS]$ for i in /sys/class/hwmon/hwmon*; do 
  echo "$i: $(cat $i/name) $(cat $i/device/path 2>/dev/null)";
done
/sys/class/hwmon/hwmon0: amdgpu 
/sys/class/hwmon/hwmon1: acpitz 
/sys/class/hwmon/hwmon2: AC 
/sys/class/hwmon/hwmon3: BAT0 
/sys/class/hwmon/hwmon4: hp 
/sys/class/hwmon/hwmon5: coretemp 
>>>>>>Hi Masrkai! ~
07:51:36[masrkai_NixOS]$ find /sys/class/hwmon/*/pwm*

/sys/class/hwmon/hwmon0/pwm1
/sys/class/hwmon/hwmon0/pwm1_enable
/sys/class/hwmon/hwmon0/pwm1_max
/sys/class/hwmon/hwmon0/pwm1_min
/sys/class/hwmon/hwmon4/pwm1_enable
>>>>>>Hi Masrkai! ~
07:51:49[masrkai_NixOS]$ lsmod | grep hp_wmi
hp_wmi                 28672  0
sparse_keymap          12288  1 hp_wmi
platform_profile       12288  1 hp_wmi
rfkill                 40960  10 hp_wmi,iwlmvm,bluetooth,cfg80211
wmi                    45056  3 hp_wmi,video,wmi_bmof
>>>>>>Hi Masrkai! ~
07:51:59[masrkai_NixOS]$ find /sys/devices -name "fan*"

/sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/hwmon/hwmon0/fan1_enable
/sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/hwmon/hwmon0/fan1_input
/sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/hwmon/hwmon0/fan1_target