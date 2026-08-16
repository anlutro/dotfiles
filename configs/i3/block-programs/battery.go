package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
)

const warnStateFile = "/tmp/.battery-warning-notification-id"

var remainingRegex = regexp.MustCompile(`(\d+):(\d+):(\d+)`)

func floatToHexChar(f float64) string {
	v := int(math.Round(f))
	if v < 0 {
		v = 0
	}
	if v > 255 {
		v = 255
	}
	return fmt.Sprintf("%02x", v)
}

func main() {
	acpiCmd := exec.Command("acpi", "-b")
	acpiOut, _ := acpiCmd.Output()

	var fullText string
	for _, line := range strings.Split(string(acpiOut), "\n") {
		if strings.Contains(line, "rate information unavailable") {
			continue
		}
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.SplitN(line, ":", 2)
		if len(parts) == 2 {
			fullText = strings.TrimSpace(parts[1])
		} else {
			fullText = line
		}
		break
	}

	// default values
	status := "Unknown"
	pct := 0.0
	remaining := ""

	if fullText != "" {
		fields := strings.Split(fullText, ",")
		if len(fields) > 0 {
			status = strings.TrimSpace(fields[0])
		}
		if len(fields) > 1 {
			pctStr := strings.TrimSpace(strings.TrimSuffix(fields[1], "%"))
			if n, err := strconv.ParseFloat(pctStr, 64); err == nil {
				pct = n
			}
		}
		if len(fields) > 2 {
			// try to extract time-like token from third field
			t := strings.TrimSpace(fields[2])
			if m := remainingRegex.FindString(t); m != "" {
				remaining = m
			}
		}
	}

	if status == "Unknown" {
		status = "Full"
	}

	var statusEmoji string
	if status == "Charging" {
		statusEmoji = "⚡️"
	} else if pct < 25 {
		statusEmoji = "🪫"
	} else {
		statusEmoji = "🔋"
	}

	text := fmt.Sprintf("%s %.0f%%", statusEmoji, pct)

	// max := 100.0
	// if b, err := ioutil.ReadFile("/sys/class/power_supply/BAT0/charge_control_end_threshold"); err == nil {
	// 	if s := strings.TrimSpace(string(b)); s != "" {
	// 		if n, err := strconv.ParseFloat(s, 64); err == nil {
	// 			max = n
	// 		}
	// 	}
	// }
	// if status != "Discharging" && max < 100 {
	// 	text += fmt.Sprintf(" (max:%.0f%%)", max)
	// }

	bar := ""
	for i := range 4 {
		// 10 / 35 / 60 / 85
		if pct > float64(i)*25+10 {
			bar += "▰"
		} else {
			bar += "▱"
		}
	}
	text += " " + bar

	if remaining != "" {
		// if remaining looks like H:M:S transform it
		if m := remainingRegex.FindStringSubmatch(remaining); m != nil {
			hours, _ := strconv.Atoi(strings.TrimLeft(m[1], "0"))
			minutes, _ := strconv.Atoi(strings.TrimLeft(m[2], "0"))
			if hours > 1 {
				remaining = fmt.Sprintf("%dh", hours)
			} else if hours > 0 {
				remaining = fmt.Sprintf("%dh%dm", hours, minutes)
			} else {
				remaining = fmt.Sprintf("%dm", minutes)
			}
		}
		text += " " + remaining
	} else if status == "Not charging" {
		text += " max"
	}

	// long/short text
	fmt.Println(text)
	fmt.Println(text)

	// color handling
	if status == "Charging" {
		if pct > 85 {
			f := 255 - (pct-90.0)/10.0*255.0
			hexchar := floatToHexChar(f)
			fmt.Printf("#%sff%s\n", hexchar, hexchar)
		}
		// notify-ok if we had a warn state
		if info, err := os.Stat(warnStateFile); err == nil && info.Size() > 0 {
			if b, err := ioutil.ReadFile(warnStateFile); err == nil {
				replaceID := strings.TrimSpace(string(b))
				// send notification
				exec.Command("notify-send", "--replace-id="+replaceID, "--urgency=low", "--expire-time=15000", "Battery warning - OK", "Battery was low but is now charging").Run()
				os.Remove(warnStateFile)
			}
		}
	} else {
		// percentage-based coloring
		if pct > 66 {
			f := 255 - (pct-67.0)/33.0*255.0
			hexchar := floatToHexChar(f)
			fmt.Printf("#%sff%s\n", hexchar, hexchar)
		} else if pct > 33 {
			f := (pct - 33.0) / 33.0 * 255.0
			hexchar := floatToHexChar(f)
			fmt.Printf("#ffff%s\n", hexchar)
		} else {
			f := pct / 33.0 * 255.0
			hexchar := floatToHexChar(f)
			fmt.Printf("#ff%s00\n", hexchar)
		}

		// low battery notifications
		if pct < 6 {
			if _, err := exec.LookPath("notify-send"); err == nil {
				replaceID := "0"
				if b, err := ioutil.ReadFile(warnStateFile); err == nil {
					if s := strings.TrimSpace(string(b)); s != "" {
						replaceID = s
					}
				}
				// call notify-send and capture printed id
				cmd := exec.Command("notify-send", "--replace-id="+replaceID, "--print-id", "--urgency=critical", "Battery warning", fmt.Sprintf("Battery level: %.0f%% - %s left", pct, remaining))
				out, _ := cmd.Output()
				if len(out) > 0 {
					ioutil.WriteFile(warnStateFile, out, 0666)
					os.Chmod(warnStateFile, 0666)
				}
			}
		}

		// suspend if battery is critically low
		if pct < 2 {
			exec.Command("systemctl", "suspend").Run()
		}
	}
}
