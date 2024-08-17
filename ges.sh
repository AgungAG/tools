#!/bin/bash

# Token Bot Telegram dan ID Chat
TELEGRAM_TOKEN="token"
CHAT_ID="chatid"

type_creator_message() {
    local message="Created by Agung Magrizal"
    local delay=0.1
    local color_green='\033[32m'
    local color_reset='\033[0m'

    for (( i=0; i<${#message}; i++ )); do
        echo -ne "${color_green}${message:$i:1}${color_reset}"
        sleep "$delay"
    done
    echo
    echo
}

# Menampilkan informasi pembuat skrip
clear  # Membersihkan layar sebelum menampilkan informasi pembuat
type_creator_message

# Fungsi untuk mendapatkan waktu saat ini dalam format YYYY-MM-DD_HH-MM-SS dengan zona waktu GMT+7
get_timestamp() {
    TZ='Asia/Bangkok' date +"%d-%m-%Y_%H:%M:%S"
}

# Fungsi untuk membuat nama file output berdasarkan target, tanggal, dan waktu
generate_output_filename() {
    local target=$1
    local timestamp=$(get_timestamp)
    echo "${target}_${timestamp}.txt"
}

# Fungsi untuk mengirim pesan ke Telegram
send_to_telegram() {
    local file_path=$1
    local message=$2
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendDocument" \
        -F chat_id="${CHAT_ID}" \
        -F document=@"${file_path}"
}

# Fungsi untuk menampilkan pesan dengan font merah dan berkedip
type_error_message() {
    local message="Vuln tidak ditemukan !!!"
    local delay=0.1
    local color_red='\033[31m'
    local color_reset='\033[0m'

    for (( i=0; i<${#message}; i++ )); do
        echo -ne "${color_red}${message:$i:1}${color_reset}"
        sleep "$delay"
    done
    echo
    echo
}

# Fungsi untuk opsi 1 (Google Dorking)
option1() {
    read -p "Masukkan query Google Dorking (contoh: site:*.ac.id): " query

    # Mengganti spasi dengan + untuk URL encoding
    encoded_query=$(echo $query | sed 's/ /+/g')

    # File output
    output_file="subdomains.txt"

    # Menghapus file output jika sudah ada
    rm -f $output_file

    # Loop untuk mengambil beberapa halaman hasil pencarian
    for page in {0..9}; do
        start=$((page * 10))
        curl -s "https://www.google.com/search?q=$encoded_query&start=$start" -A "Mozilla/5.0" | \
        grep -oP '(?<=<a href="/url\?q=)(https?://[^&]+)' | \
        grep -oP 'https?://[^/]*' | \
        sed 's|https://||;s|www.||' | \
        sort -u >> $output_file
    done

    # Menghapus duplikat dan menyimpan hasil akhir
    sort -u $output_file -o $output_file

    echo "Subdomain hasil pencarian telah disimpan di $output_file"
    send_to_telegram "$output_file" "Hasil Google Dorking untuk query: ${query}"
    clear
    type_creator_message
}

# Fungsi untuk opsi 2 (Vuln XSS)
option2() {
   echo -n "Masukkan target Vuln XSS : "
   read target
    output_filename=$(generate_output_filename "$target")
    results=$(echo "$target" | waybackurls | urldedupe -s -qs -ne | gf xss | qsreplace '"><img src=x onerror=alert(1)>' | freq | egrep -v 'Not')

    if echo "$results" | grep -q "XSS FOUND"; then
        echo "Vuln XSS" > "$output_filename"
        echo "$results" >> "$output_filename"
        echo "Hasil telah dikirim ke $output_filename"
        send_to_telegram "$output_filename" "Hasil Vuln XSS : ${target}"
        clear
        type_creator_message
    else
        type_error_message
    fi
}

# Fungsi untuk opsi 3 (Vuln Lain)
option3() {
    echo -n "Masukkan target Vuln Lain : "
    read target
    output_filename=$(generate_output_filename "$target")
    results=$(echo "$target" | gau --fc 200 2>/dev/null | urldedupe -s -qs | gf lfi redirect sqli-error sqli ssrf ssti xss xxe | qsreplace FUZZ | grep FUZZ | nuclei -silent -t ~/nuclei-templates/dast/vulnerabilities/ -dast)

    if [ -n "$results" ]; then
        echo "Vuln Lain" > "$output_filename"
        echo "$results" >> "$output_filename"
        echo "Hasil telah dikirim ke $output_filename"
        send_to_telegram "$output_filename" "Hasil Vuln Lain : ${target}"
        clear
        type_creator_message
    else
        type_error_message
    fi
}

# Menu utama
while true; do
    echo "Pilih Opsi:"
    echo "1) Google Dorking"
    echo "2) Vuln XSS"
    echo "3) Vuln Lain"
    echo "4) Keluar"

    #Meminta input opsi dari pengguna
    read -p "Pilih nomor opsi: " pilihan

    case $pilihan in
        1)
            option1
            ;;
        2)
            option2
            ;;
        3)
            option3
            ;;
        4)
            echo "Keluar..."
            break
            ;;
        *)
            echo "Pilihan tidak valid, silakan coba lagi."
            ;;
    esac
done
