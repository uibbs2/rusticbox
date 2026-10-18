#!/bin/bash
#set -x

case $0 in
	basename|*/basename)
		[[ -z "$1" ]] && exit 0
		path="$1"
		while [[ "$path" == */ && "$path" != / ]]; do
			path="${path%/}"
		done
		result="${path##*/}"
		[[ -z "$result" ]] && result="$path"
		[[ -n "$2" ]] && result="${result%$2}"
		printf '%s\n' "$result"
	;;

#	cal|*/cal)
#		reverse="\x1b[7m"
#		normal="\x1b[m"
#		year=$(date +%Y)
#		month_num=$(date +%m)
#		month_name=$(date +%B)
#		today=$(date +%e|tr -d ' ')
#		first_day_dow=$(date -d "${year}-${month_num}-01" +%u 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-${month_num}-01" "+%u")
#		days_in_month=31
#		case "$month_num" in
#			04|06|09|11) days_in_month=30 ;;
#			02) (( days_in_month = ((year % 4==0 && year % 100!=0) || #(year % 400==0)) ? 29 : 28 )) ;;
#		esac
#		weekdays=()
#		for i in {0..6}; do
#			d_name=$(date -d "2023-01-02 +$i days" +%a 2>/dev/null || date -j -v+${i}d -f "%Y-%m-%d" "2023-01-02" "+%a" 2>/dev/null)
#			weekdays+=("${d_name:0:2}")
#		done
#		printf "\n	 %s %s\n" "$month_name" "$year"
#		for w in "${weekdays[@]}"; do
#			printf "%2s " "$w"
#		done
#		printf "\n"
#		current_col=1
#		while (( current_col < first_day_dow )); do
#			printf "   "
#			((current_col++))
#		done
#		day=1
#		while (( day <= days_in_month )); do
#			day_str=""
#			printf -v day_str "%2d" "$day"
#			(( day == today )) && fmt="${reverse}${day_str}${normal}" || fmt="$day_str"
#			printf "%b " "$fmt"
#			(( current_col % 7 == 0 )) && printf "\n"
#			((day++))
#			((current_col++))
#		done
#		(( (current_col - 1) % 7 != 0 )) && printf "\n"
#		printf "\n"
#	;;

	cal|*/cal)
		reverse="\x1b[7m"
		normal="\x1b[m"
		vertical=false
		while [[ $# -gt 0 ]]; do
			case "$1" in
				-v) vertical=true; shift ;;
				*) exit 4 ;;
			esac
		done
		year=$(date +%Y)
		month_num=$(date +%m)
		month_name=$(date +%B)
		today=$(date +%e|tr -d ' ')
		first_day_dow=$(date -d "${year}-${month_num}-01" +%u 2>/dev/null || date -j -f "%Y-%m-%d" "${year}-${month_num}-01" "+%u")
		days_in_month=31
		case "$month_num" in
			04|06|09|11) days_in_month=30 ;;
			02) (( days_in_month = ((year % 4==0 && year % 100!=0) || (year % 400==0)) ? 29 : 28 )) ;;
		esac
		weekdays=()
		for i in {0..6}; do
			d_name=$(date -d "2023-01-02 +$i days" +%a 2>/dev/null || date -j -v+${i}d -f "%Y-%m-%d" "2023-01-02" "+%a" 2>/dev/null)
			weekdays+=("${d_name:0:2}")
		done
		if "$vertical"; then
			# Formato Verticale: giorni della settimana in riga, settimane in colonna
			printf "\n	%s %s\n\n" "$month_name" "$year"
			
			# Calcola la data del lunedì della settimana in cui cade il 1° del mese
			base_monday=$(( 2 - first_day_dow ))

			for (( d_idx=1; d_idx<=7; d_idx++ )); do
				printf "%2s " "${weekdays[d_idx-1]}"
				
				for (( w=0; w<6; w++ )); do
					# Se l'inizio di questa settimana supera i giorni del mese, interrompiamo la riga
					week_start=$(( base_monday + w * 7 ))
					(( week_start > days_in_month )) && break

					d=$(( base_monday + (d_idx - 1) + (w * 7) ))
					
					if (( d < 1 || d > days_in_month )); then
						printf "   "
					else
						printf -v day_str "%2d" "$d"
						(( d == today )) && fmt="${reverse}${day_str}${normal}" || fmt="$day_str"
						printf "%b " "$fmt"
					fi
				done
				printf "\n"
			done
			printf "\n"
		else
			# Formato Orizzontale (default)
			printf "\n	%s %s\n" "$month_name" "$year"
			for w in "${weekdays[@]}"; do
				printf "%2s " "$w"
			done
			printf "\n"
			current_col=1
			while (( current_col < first_day_dow )); do
				printf "   "
				((current_col++))
			done
			day=1
			while (( day <= days_in_month )); do
				day_str=""
				printf -v day_str "%2d" "$day"
				(( day == today )) && fmt="${reverse}${day_str}${normal}" || fmt="$day_str"
				printf "%b " "$fmt"
				(( current_col % 7 == 0 )) && printf "\n"
				((day++))
				((current_col++))
			done
			(( (current_col - 1) % 7 != 0 )) && printf "\n"
			printf "\n"
		fi
	;;

	cat|*/cat)
		#echo "$(<$1)" ;;
		[[ -z "$1" || "$1" == "-" ]] || { [[ -r "$1" ]] || exit 1; exec < "$1"; }
		while IFS= read -r line || [[ -n "$line" ]]; do
			printf '%s\n' "$line"
		done
	;;

	chat|*/chat)
		timeout=10
		while [[ $# -gt 0 ]]; do
			expect="$1"; send="${2:-}"; shift 2
			matched=0
			while IFS= read -r -t "$timeout" line; do
				[[ "$line" == *"$expect"* ]] && { matched=1; break; }
			done
			(( matched == 0 )) && exit 1
			[[ -n "$send" ]] && printf '%s\r\n' "$send"
		done
	;;

	clear|*/clear) printf "\x1b[0m\x1b[H\x1b[2J\x1b3J" >&2 ;;

	colrm|*/colrm)
		start="${1:-}"
		stop="${2:-}"
		[[ -n "$start" && ! "$start" =~ ^[0-9]+$ ]] && exit 1
		[[ -n "$stop" && ! "$stop" =~ ^[0-9]+$ ]] && exit 2
		awk -v start="$start" -v stop="$stop" '{
			if (start=="") print
			else if (stop == "") print substr($0, 1, start - 1)
			else print substr($0, 1, start - 1) substr($0, stop + 1)
		}'
	;;

	cryptpw|*/cryptpw)
		[[ -z "$1" ]] && exit 1
		pass="$1"
		salt="${2:-}"
		[[ "$salt" =~ ^\$5\$([^$]+)\$ ]] && salt="${BASH_REMATCH[1]}"
		[[ -z "$salt" ]] && read -r salt < /proc/sys/kernel/random/uuid && salt="${salt%%-*}"
		printf '%s%s' "$salt" "$pass"|sha256sum|awk -v s="$salt" '{print "$5$" s "$" $1}'
	;;

	cut|*/cut)
		delim=""
		fields=""
		chars=""
		while [[ $# -gt 0 ]]; do
			case "$1" in
				-d) delim="$2"; shift 2 ;;
				-f) fields="$2"; shift 2 ;;
				-c) chars="$2"; shift 2 ;;
				*) shift ;;
			esac
		done
		awk -v d="$delim" -v f="$fields" -v c="$chars" 'BEGIN {	FS = (d == "" ? "\t" : d); OFS = FS	}
			c != "" {
				split(c,range,"-")
				print (length(range) > 1 ? substr($0, range[1], range[2] - range[1] + 1) : substr($0, c, 1))
				next
			}
			f != "" {
				n = split(f,parts,",")
				out = ""
				for (i=1;i<=n;i++) {
					if (parts[i] ~ /-/) {
						split(parts[i],rng,"-")
						for (j=rng[1];j<=rng[2];j++) out = (out == "" ? $j : out OFS $j)
					} else {
						idx = parts[i]
						out = (out == "" ? $idx : out OFS $idx)
					}
				}
				print out
				next
			}
			{ print }'
	;;

	ddate|*/ddate)
		y=$(date +%Y)
		doy=$(date +%j)
		yold=$((y + 1166))
		(( (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0) )) && is_leap=1 || is_leap=0
		(( is_leap == 1 && doy == 60 )) && { printf 'St. Tib'\''s Day, YOLD %d\n' "$yold"; exit; }
		(( is_leap == 1 && doy > 60 )) && ((doy--))
		season_idx=$(( (doy - 1) / 73 ))
		season_day=$(( ((doy - 1) % 73) + 1 ))
		dow=$(( (doy - 1) % 5 ))
		seasons=("Chaos" "Discord" "Confusion" "Bureaucracy" "The Aftermath")
		days=("Sweetmorn" "Boomtime" "Pungenday" "Prickle-Prickle" "Setting Orange")
		if (( season_day == 5 )); then
			case "$season_idx" in
				0) holyday="\nCelebrate Mungday" ;;
				1) holyday="\nCelebrate SJDay" ;;
				2) holyday="\nCelebrate Maladay" ;;
				3) holyday="\nCelebrate BureaucratDay" ;;
				4) holyday="\nCelebrate Afftermination" ;;
			esac
		elif (( season_day == 50 )); then
			case "$season_idx" in
				0) holyday="\nCelebrate Chaofux" ;;
				1) holyday="\nCelebrate Discofux" ;;
				2) holyday="\nCelebrate Confux" ;;
				3) holyday="\nCelebrate Bureafux" ;;
				4) holyday="\nCelebrate Afterfux" ;;
			esac
		fi
		suffix="th"
		(( season_day % 10 == 1 && season_day != 11 )) && suffix="st"
		(( season_day % 10 == 2 && season_day != 12 )) && suffix="nd"
		(( season_day % 10 == 3 && season_day != 13 )) && suffix="rd"
		printf 'Today is %s, the %d%s day of %s in the YOLD %d%s\n' "${days[dow]}" "$season_day" "$suffix" "${seasons[season_idx]}" "$yold" "$holiday"
	;;

	diff|*/diff)
		file1="${1:-}"
		file2="${2:-}"
		[[ -z "$file2" ]] && file2="-"
		awk 'NR==FNR { f1[NR]=$0; next }
			{ f2[FNR]=$0 } END {
				max = (length(f1)>length(f2) ? length(f1) : length(f2))
				for (i=1;i<=max;i++) {
					if (f1[i] != f2[i]) {
						if (!(i in f1)) printf "> %s\n", f2[i]
						else if (!(i in f2)) printf "< %s\n", f1[i]
						else {
							printf "< %s\n", f1[i]
							printf "> %s\n", f2[i]
						}
					}
				}
			}' "$file1" "$file2"
	;;

	dirname|*/dirname)
		[[ -z "$1" ]] && { echo "."; exit 0; }
		path="$1"
		while [[ "$path" == */ && "$path" != / ]]; do
			path="${path%/}"
		done
		result="${path%/*}"
		if [[ "$path" == "$result" ]]; then
			result="."
		elif [[ -z "$result" ]]; then
			result="/"
		fi
		printf '%s\n' "$result"
	;;

	domainname|*/domainname)
		kern="/proc/sys/kernel/domainname"
		[[ -n "$1" ]] && echo "$1" > "$kern" || printf '%s\n' "$(< "$kern")"
	;;

	false|*/false) exit 1 ;;

	fortune|*/fortune)
		file="${1:-/usr/share/games/fortunes/fortunes}"
		[[ -r "$file" ]] || exit 1
		awk 'BEGIN { srand(); n = 1 }
			$0 == "%%" { n++; next }
			{ fortunes[n] = (fortunes[n] == "" ? $0 : fortunes[n] "\n" $0) }
			END {
				if (n > 0) {
					idx = int(rand() * n) + 1
					print fortunes[idx]
				}
			}' "$file"
	;;

	free|*/free)
		awk '$2+0!=0 {lines[++n]=$0}END{half=int((n + 1)/2)
			for (i=1;i<=half;i++) {
				left=lines[i]
				right=(i+half<=n) ? lines[i+half] : ""
				printf "%-40s %s\n", left, right
		}}' < /proc/meminfo
	;;

	fromdos|*/fromdos)
		file="${1:-}"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk '{ sub(/\r$/, ""); print }' ${file:+"$file"}
	;;

	grep|*/grep)
		[[ -z "$1" ]] && exit 1
		invert=0
		pattern=""
		file=""
		[[ "$1" == "-v" ]] && { invert=1; shift; }
		pattern="$1"
		(( invert )) && sed_cmd="/$pattern/!p" || sed_cmd="/$pattern/p"
		sed -n "$sed_cmd" $2
	;;

	hangman|*/hangman)
		if [[ -n "$1" ]]; then
			[[ -r "$1" ]] || exit 1
			words=()
			while IFS= read -r line || [[ -n "$line" ]]; do
				[[ -n "$line" ]] && words+=("$line")
			done < "$1"
			[[ ${#words[@]} -eq 0 ]] && exit 1
		else
			words=("bash" "terminal" "script" "modular" "pipeline" "pager" "awk" "syntax" "buffer")
		fi
		while true; do
			word="${words[RANDOM % ${#words[@]}]}"
			len=${#word}
			guessed_letters=""
			mistakes=0
			max_mistakes=6
			echo "=== BASH HANGMAN ==="
			while (( mistakes < max_mistakes )); do
				display=""
				complete=true
				for (( i=0; i<len; i++ )); do
					char="${word:i:1}"
					if [[ "$guessed_letters" == *"$char"* ]]; then
						display+="$char "
					else
						display+="_ "
						complete=false
					fi
				done
				if $complete; then
					printf "\nParola: %s\n" "$display"
					echo "Hai vinto! La parola era: $word"
					break
				fi
				printf "\nParola: %s\n" "$display"
				echo "Errori: $mistakes / $max_mistakes | Lettere provate: ${guessed_letters:-Nessuna}"

				printf '%s' "Inserisci una lettera: "
				IFS= read -r -n 1 -s guess
				echo
				[[ ! "$guess" =~ [a-z] ]] && continue
				[[ "$guessed_letters" == *"$guess"* ]] && continue
				guessed_letters+="$guess"
				if [[ "$word" != *"$guess"* ]]; then
					((mistakes++))
					echo "Lettera non presente!"
				fi
			done
			(( mistakes >= max_mistakes )) && echo -e "\nHai perso! La parola corretta era: $word"
			printf '%s' "Vuoi giocare ancora? (s/n): "
			IFS= read -r -n 1 -s play_again
			echo
			[[ "$play_again" != "s" && "$play_again" != "S" ]] && { echo "Alla prossima!"; exit 0; }
		done
	;;

	head|*/head)
		lines=10
		[[ "$1" == "-n" ]] && { lines="$2"; shift 2; }
		[[ "$lines" =~ ^[0-9]+$ ]] || exit 1
		file="${1:-}"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk -v n="$lines" 'NR<=n {print} NR>n {exit}' $1
	;;

	hostname|*/hostname)
		# originariamente mu-hostname by A.Manzini <linux@netbusiness.it> 
		H=/proc/sys/kernel/hostname
		[[ -z "$1" ]] && printf '%s\n' "$(< "$H")" || echo "$1">"$H"
	;;

	id|*/id)
		groups_str=""
		g_ids=()
		while IFS=$'\t:' read -r key val _; do
			case "$key" in
				Uid) read -r uid euid _ <<< "$val" ;;
				Gid) read -r gid egid _ <<< "$val" ;;
				Groups) read -r -a g_ids <<< "$val" ;;
			esac
		done < /proc/self/status
		uname=$(awk -F: -v id="$uid" '$3 == id {print $1; exit}' /etc/passwd)
		gname=$(awk -F: -v id="$gid" '$3 == id {print $1; exit}' /etc/group)
		for g in "${g_ids[@]}"; do
			gn=$(awk -F: -v id="$g" '$3 == id {print $1; exit}' /etc/group)
			groups_str+="${g}(${gn:-$g}),"
		done
		groups_str="${groups_str%,}"
		printf 'uid=%s(%s) gid=%s(%s) groups=%s\n' "$uid" "${uname:-unknown}" "$gid" "${gname:-unknown}" "$groups_str"
	;;

	killall|*/killall)
		[[ $1 == "-l" ]] && { kill -l; exit; }
		[[ "$1" == -* ]] && { SIGNAL="$1"; shift; kill "$SIGNAL" $(/bin/pidof "$@"); } || kill $(/bin/pidof "$@")
	;;

	length|*/length)
		[[ $# -gt 0 ]] && input="$*" || { IFS= read -r -d '' input || true; }
		awk -v s="$input" 'BEGIN { print length(s) }'
	;;

	life|*/life)
		width=50
		height=14
		density=40
		delay_factor=3
		c_red=""
		c_gre=""
		c_yel=""
		c_nrm=""
		nl=$'\n'
		l_born="o"
		l_aliv="O"
		l_dead="x"
		l_empt=" "
		while [[ $# -gt 0 ]]; do
			case "$1" in
				-w)
					[[ -n "$2" && "$2" =~ ^[0-9]+$ ]] || exit 2
					(( 10 <= $2 && $2 <= 70 )) || exit 3
					width="$2"
					shift 2
					;;
				-h)
					[[ -n "$2" && "$2" =~ ^[0-9]+$ ]] || exit 2
					(( 5 <= $2 && $2 <= 21 )) || exit 3
					height="$2"
					shift 2
					;;
				-d)
					[[ -n "$2" && "$2" =~ ^[0-9]+$ ]] || exit 2
					(( 5 <= $2 && $2 <= 95 )) || exit 3
					density="$2"
					shift 2
					;;
				-t)
					[[ -n "$2" && "$2" =~ ^[0-9]+$ ]] || exit 2
					(( 1 <= $2 && $2 <= 10 )) || exit 3
					delay_factor="$2"
					shift 2
					;;
				-c)
					c_red=$'\x1b[1;31m'
					c_gre=$'\x1b[1;32m'
					c_yel=$'\x1b[1;33m'
					c_nrm=$'\x1b[m'
					shift
					;;
				*)
					exit 4
					;;
			esac
		done
		delay=$(( delay_factor == 10 ? 1 : 0 )).$(( delay_factor == 10 ? 0 : delay_factor ))
		declare -A grid next_grid
		for ((y = 1; y <= height; y++)); do
			for ((x = 1; x <= width; x++)); do
				(( (RANDOM % 100) < density )) && grid["$x,$y"]=1 || grid["$x,$y"]=0
			done
		done
		while true; do
			out=$'\x1b[H\x1b[2J=== GAME OF LIFE === (press q to quit)'"$nl"$'Legend: '${c_yel}${l_born}${c_nrm}' = born | '${c_gre}${l_aliv}${c_nrm}' = alive | '${c_red}${l_dead}${c_nrm}' = died'"$nl$nl"
			for ((y = 1; y <= height; y++)); do
				line=""
				for ((x = 1; x <= width; x++)); do
					case "${grid["$x,$y"]}" in
						1) line+="${c_yel}${l_born}${c_nrm}" ;;
						2) line+="${c_gre}${l_aliv}${c_nrm}" ;;
						3) line+="${c_red}${l_dead}${c_nrm}" ;;
						*) line+="${l_empt}" ;;
					esac
				done
				out+="|$line|$nl"
			done
			printf '%s' "$out"
			for ((y = 1; y <= height; y++)); do
				for ((x = 1; x <= width; x++)); do
					neighbors=0
					for ((dy = -1; dy <= 1; dy++)); do
						for ((dx = -1; dx <= 1; dx++)); do
							(( dx == 0 && dy == 0 )) && continue
							nx=$(( x + dx ))
							ny=$(( y + dy ))
							(( nx < 1 )) && nx=width
							(( nx > width )) && nx=1
							(( ny < 1 )) && ny=height
							(( ny > height )) && ny=1
							val="${grid["$nx,$ny"]:-0}"
							(( val == 1 || val == 2 )) && ((neighbors++))
						done
					done
					current="${grid["$x,$y"]:-0}"
					if (( current == 1 || current == 2 )); then
						next_grid["$x,$y"]=$(( (neighbors == 2 || neighbors == 3) ? 2 : 3 ))
					else
						next_grid["$x,$y"]=$(( neighbors == 3 ? 1 : 0 ))
					fi
				done
			done
			for ((y = 1; y <= height; y++)); do
				for ((x = 1; x <= width; x++)); do
					grid["$x,$y"]=${next_grid["$x,$y"]}
				done
			done
			if IFS= read -s -t "$delay" -n 1 k </dev/tty ; then
				[[ "${k,,}" == "q" ]] && { printf "\nGame exited.\n"; exit 0; }
			fi
		done
	;;

	lsmod|*/lsmod)
		printf "%-24s %-15s %-10s\n" "Module" "Pages" "Status"
		awk '{printf "%-24s %-15s %-10s\n",$1,$2,$5}' </proc/modules|sort
	;;

	minmaxavg|*/minmaxavg)
		[[ -z "$1" || "$1" == "-" || -r "$1" ]] || exit 1
		awk '{ sub(/\r$/, "")
			if ($1 ~ /^-?[0-9]+(\.[0-9]+)?$/) {
				val = $1 + 0
				if (count == 0) {
					min = val
					max = val
				} else {
					if (val < min) min = val
					if (val > max) max = val
				}
				sum += val
				count++
			} } END {
				if (count == 0) exit 1
				avg = sum / count
				printf "%s %s %s\n", min, max, avg
		}' ${1:+"$1"}
	;;

	more|*/more)
		file="${1:-}"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		start=1
		lines=23
		while true; do
			awk -v start="$start" -v n="$lines" '
				NR < start { next }
				NR >= start && NR < start + n {
				print
				printed++
			} END {
				if (printed < n) exit 0;
				else exit 2;
			}' ${file:+"$file"}
		awk_status=$?
		[[ $awk_status -eq 0 ]] && exit 0
		printf '%s' "More? (a) again, (q) quit, (space) next page, (enter) next line: "
		IFS= read -r -n 1 -s choice
		echo
		case "$choice" in
			q|Q) exit 0 ;;
			a|A) start=1 ;;
			" ") start=$((start + lines)) ;;
			#""|$'\n') start=$((start + 1)) ;;
			*) start=$((start + 1)) ;;
		esac
	done
	;;

	mv|*/mv)
		(( $# < 2 )) && { echo "uso: mv <origine> <destinazione>"; exit 2; }
		[[ ! -e "$1" ]] && { echo "origine non esiste"; exit 1; }
		cp -- "$1" "$2" && rm -- "$1"
	;;

	netstat|*/netstat)
		[[ -r /proc/net/tcp ]] || exit 1
		awk 'function h2d(h) { return "0x" h+0 }
			function hexip(h) { return sprintf("%d.%d.%d.%d", h2d(substr(h,7,2)), h2d(substr(h,5,2)), h2d(substr(h,3,2)), h2d(substr(h,1,2))) }
			function hexport(h) { return h2d(substr(h,1,4)) }
			BEGIN {
				states["01"] = "ESTABLISHED"
				states["0A"] = "LISTEN"
				states["02"] = "SYN_SENT"
				states["03"] = "SYN_RECV"
				states["06"] = "TIME_WAIT"
				states["08"] = "CLOSE_WAIT"
				states["09"] = "LAST_ACK"
				printf "%-5s %-23s %-23s %-12s\n", "Proto", "Local Address", "Foreign Address", "State"
			} NR > 1 {
				split($2, local, ":")
				split($3, remote, ":")
				l_ip = hexip(local[1]); l_port = hexport(local[2])
				r_ip = hexip(remote[1]); r_port = hexport(remote[2])
				st = states[$4] ? states[$4] : $4
				printf "tcp   %-23s %-23s %-12s\n", l_ip ":" l_port, r_ip ":" r_port, st
			}' /proc/net/tcp
	;;

	pidof|*/pidof)
		[[ -z "$1" ]] && exit 1
		target="$1"
		pids=()
		for proc_dir in /proc/[0-9]*; do
			[[ -r "$proc_dir/stat" ]] || continue
			comm=$(awk -F'[()]' '{print $2}' "$proc_dir/stat" 2>/dev/null)
			[[ "$comm" == "$target" ]] && { pid="${proc_dir##*/}"; pids+=("$pid"); }
		done
		(( ${#pids[@]} > 0 )) && printf '%s\n' "${pids[*]}"
	;;

	ps|*/ps)
		printf "%-7s %-6s %-s\n" "PID" "STAT" "COMMAND"
		for proc_dir in /proc/[0-9]*; do
			[[ -r "$proc_dir/stat" ]] || continue
			pid="${proc_dir##*/}"
			read -r stat comm < <(awk -F'[()]' '{split($3, a, " "); print a[1], $2}' "$proc_dir/stat" 2>/dev/null)
			[[ -r "$proc_dir/cmdline" ]] && cmdline=$(awk 'BEGIN {ORS=""} {gsub(/\0/, " "); print}' "$proc_dir/cmdline" 2>/dev/null)
			[[ -z "$cmdline" ]] && cmdline="[$comm]"
			printf "%-7s %-6s %-s\n" "$pid" "$stat" "$cmdline"
		done
	;;

	pwd|*/pwd) printf '%s\n' "$PWD" ;;

	reset|*/reset) printf "\x1bc\x1b]104\x07\x1b[!p\x1b[?3;4l\x1b[4l\x1b>\x1b[?69l" >&2 ;;

	rot13|*/rot13)
		file="${1:-}"
		[[ -n "$file" && "$file" != "-" ]] && [[ -r "$file" ]] || exit 1
		awk '{ print translit($0, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "nopqrstuvwxyzabcdefghijklmNOPQRSTUVWXYZABCDEFGHIJKLM") }' ${file:+"$file"}
	;;

	sleep|*/sleep)
		seconds="${1:-1}";
		[[ "$seconds" =~ ^-?[0-9]+$ ]] || exit 1
		for ((i = 0; i < seconds; i++)); do
			read -t 1 -n 1 2>/dev/null || true
		done
	;;
	
	sort|*/sort) awk '{a[NR]=$0}END{asort(a);for (i=1;i<= NR;i++) print a[i]}' ${1:+"$1"} ;;

	strings|*/strings)
		file=""
		min_len="4"
		if [[ $# -eq 1 ]]; then
			[[ "$1" =~ ^[0-9]+$ ]] && min_len="$1" || file="$1"
		elif [[ $# -ge 2 ]]; then
			file="$1"
			min_len="$2"
		fi
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk -v min="$min_len" 'BEGIN {
			print_chars = " !\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
			for (i=1;i<=length(print_chars);i++) valid[substr(print_chars, i, 1)] = 1
			valid["\t"] = 1
		} {
			n = length($0)
			buf = ""
			for (i=1;i<=n;i++) {
				c = substr($0, i, 1)
				if (c in valid) {
					buf = buf c
				} else {
					if (length(buf) >= min) print buf
					buf = ""
				}
			}
			if (length(buf) >= min) print buf
		}' ${file:+"$file"}
	;;

	tail|*/tail)
		lines=10
		[[ "$1" == "-n" ]] && { lines="$2"; shift 2; }
		[[ "$lines" =~ ^[0-9]+$ ]] || exit 1
		file="$1"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk -v n="$lines" '{
			buf[(NR-1) % n] = $0
			} END {
				total = (NR < n) ? NR : n
				start = (NR < n) ? 0 : NR % n
				for (i=0;i<total;i++) print buf[(start + i) % n]
			}' ${file:+"$file"}
	;;

	todos|*/todos)
		file="${1:-}"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk 'BEGIN { ORS = "\r\n" }
			{ sub(/\r$/, ""); print }' ${file:+"$file"}
	;;

	touch|*/touch)
		file="${1:-}"
		[[ -z "$file" ]] && exit 1
		>> "$file"
	;;

	true|*/true) exit 0 ;;

	tty|*/tty)
		[[ -t 0 ]] && { link_info=$(ls -l /proc/self/fd/0 2>/dev/null); printf '%s\n' "${link_info##*-> }"; } || exit 1
	;;

	uname|*/uname)
		opt="${1:- -s}"
		proc_v=""
		[[ -r /proc/version ]] && proc_v=$(< /proc/version)
		sys="Linux"
		release="unknown"
		version="unknown"
		if [[ -n "$proc_v" ]]; then
			sys="${proc_v%% *}"
			remainder="${proc_v#* version }"
			release="${remainder%% *}"
			[[ "$remainder" == *\#* ]] && version="#${remainder#*\#}" || version="$remainder"
		fi
		case "$opt" in
			-s) printf '%s\n' "$sys" ;;
			-r) printf '%s\n' "$release" ;;
			-v) printf '%s\n' "$version" ;;
			-a) printf '%s %s %s\n' "$sys" "$release" "$version" ;;
			*) exit 1 ;;
		esac
	;;
	
	uptime|*/uptime)
		raw_uptime=""
		[[ -r /proc/uptime ]] && read -r raw_uptime _ < /proc/uptime
		[[ -z "$raw_uptime" ]] && exit 1
		total_sec="${raw_uptime%.*}"
		days=$(( total_sec / 86400 ))
		hours=$(( (total_sec % 86400) / 3600 ))
		minutes=$(( (total_sec % 3600) / 60 ))
		seconds=$(( total_sec % 60 ))
		result=""
		(( days == 1 )) && result+="$days day, " || (( days > 1 )) && result+="$days days, "
		(( days > 0 || hours > 0 )) && { (( hours == 1 )) && result+="$hours hour " || result+="$hours hours "; }
		(( days > 0 || hours > 0 || minutes > 0 )) && { (( minutes == 1 )) && result+="$minutes minute and " || result+="$minutes minutes and "; }
		result+="$seconds seconds"
		read -r l1 l2 l3 _ < /proc/loadavg > /dev/null 2>&1
		printf '%s, up %s - load avg: %s %s %s\n' "$(date +%T)" "$result" "$l1" "$l2" "$l3"
	;;

	uuid|*/uuid)
		[[ -r /proc/sys/kernel/random/uuid ]] && { < /proc/sys/kernel/random/uuid; exit 0; }
		hex=$(hexdump -n 16 -e '16/1 "%02x"' /dev/urandom)
		hex="${hex,,}"
		part1="${hex:0:8}"
		part2="${hex:8:4}"
		part3="4${hex:13:3}"
		var_char="${hex:16:1}"
		printf -v mapped_var '%x' $(( (0x$var_char & 3) | 8 ))
		part4="$mapped_var${hex:17:3}"
		part5="${hex:20:12}"
		printf '%s-%s-%s-%s-%s\n' "$part1" "$part2" "$part3" "$part4" "$part5"
	;;

	wc|*/wc)
		file="${1:-}"
		[[ -z "$file" || "$file" == "-" || -r "$file" ]] || exit 1
		awk '{
			lines++
			words+=NF
			bytes+=length($0)+length(RT)
		} END {
			printf "%8d %8d %8d\n", lines + 0, words + 0, bytes + 0
		}' ${file:+"$file"}
	;;

	whoami|*/whoami)
		while IFS=: read -r name _ uid _; do
			(( uid == EUID )) && { printf '%s\n' "$name"; exit; }
		done < /etc/passwd || printf '%s\n' "${USER:-unknown}"
	;;

	yes|*/yes)
		msg="${@:-y}"
		for ((;;)); do
			printf '%s\n' "$msg"
		done
	;;

	zcat|*/zcat) gzip -dc $@ ;;

	zless|*/zless) gzip -dc $@|less ;;

	*) printf 'No function defined fors: %s\nAvailable functions:\n\n' "$0"
		awk '{ if ((i = index($0, "|*"))) {
				s = substr($0, 1, i - 1)
				sub(/^[ \t]+/, "", s)
				if (s !~ /^awk/) {
					printf "%-18s", s
					if (++count % 4 == 0) print ""
				}
			}
		} END { if (count % 4 != 0) print ""}' $0
		exit 254
esac
exit 0