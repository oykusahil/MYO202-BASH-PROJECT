#!/bin/bash
# ==============================================================================
# Öykü Sahil
# 2320171036
# 1. https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=XV1hBlK87e
# 2. https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=EoPfJnn2L7
# 3. https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=zXztnN86nv
# 4. https://credsverse.com/credentials/07d1985b-a8ab-454a-9fe4-1f31f03bd5e0
# ==============================================================================

echo "Tarih: $(date -Iseconds)" > report.log
echo "--------------------------------" >> report.log

SISTEM="$(uname -s)"

if [[ "$SISTEM" == *"MINGW"* || "$SISTEM" == *"CYGWIN"* || "$SISTEM" == *"NT"* ]]; then
    echo "Sistem: Windows" >> report.log
    
    echo -n "Islemci Bilgisi: " >> report.log
    wmic cpu get Name | tail -n +2 | tr -d '\r' | grep -v '^$' | sed 's/[[:space:]]*$//' >> report.log
    
    echo "RAM Detaylari:" >> report.log
    wmic memorychip get Manufacturer, PartNumber, SerialNumber, Capacity | tail -n +2 | tr -d '\r' | grep -v '^$' | while read -r line; do
        cap=$(echo "$line" | awk '{print $1}')
        man=$(echo "$line" | awk '{print $2}')
        part=$(echo "$line" | awk '{print $3}')
        ser=$(echo "$line" | awk '{print $4}')
        echo "  -> Uretici: $man | Parca No: $part | Seri No: $ser | Kapasite: $((cap / 1024 / 1024 / 1024)) GB ($cap Byte)" >> report.log
    done
    
    echo -n "Anakart Bilgisi (Uretici / Model / SeriNo): " >> report.log
    wmic baseboard get Manufacturer, Product, SerialNumber | tail -n +2 | tr -d '\r' | grep -v '^$' | awk '{print $1 " " $2 " " $3 " / " $4 " / " $5}' | sed 's/ \/  *\/ / \/ Bilinmiyor \/ /' >> report.log
    echo -n "Anakart UUID: " >> report.log
    wmic csproduct get UUID | tail -n +2 | tr -d '\r' | grep -v '^$' | sed 's/[[:space:]]*$//' >> report.log
    
    echo "Disk Detaylari:" >> report.log
    wmic diskdrive get Model, SerialNumber, Size | tail -n +2 | tr -d '\r' | grep -v '^$' | while read -r line; do
        size=$(echo "$line" | awk '{print $failed; print $NF}') 
        d_model=$(echo "$line" | awk '{$NF=""; $(NF-1)=""; print $0}' | sed 's/[[:space:]]*$//')
        d_serial=$(echo "$line" | awk '{print $(NF-1)}')
        d_size=$(echo "$line" | awk '{print $NF}')
        echo "  -> Model: $d_model | Seri No: $d_serial | Kapasite: $((d_size / 1024 / 1024 / 1024)) GB ($d_size Byte)" >> report.log
    done
    
    echo -n "MAC Adresi: " >> report.log
    getmac | grep -i "tcpip" | head -n 1 | awk '{print $1}' | tr -d '\r' >> report.log

elif [[ "$SISTEM" == "Darwin" ]]; then
    echo "Sistem: Macbook (macOS)" >> report.log
    
    echo -n "Islemci Bilgisi: " >> report.log
    system_profiler SPHardwareDataType | grep "Processor Name" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo "RAM Detaylari:" >> report.log
    system_profiler SPMemoryDataType | grep -E "Size:|Type:|Manufacturer:|Part Number:|Serial Number:" | awk -F': ' '{print $2}' | paste - - - - - | while read -r size type man part ser; do
        echo "  -> Uretici: $man | Model/Tip: $type | Parca No: $part | Seri No: $ser | Kapasite: $size" >> report.log
    done
    
    echo -n "Anakart Bilgisi (Model): " >> report.log
    system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d':' -f2 | sed 's/^ //' >> report.log
    echo -n "Anakart UUID: " >> report.log
    system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo "Disk Detaylari:" >> report.log
    system_profiler SPStorageDataType | grep -E "Device Name:|Size:|Volume UUID:" | awk -F': ' '{print $2}' | paste - - - | while read -r name size uuid; do
        echo "  -> Model: $name | Seri No/UUID: $uuid | Kapasite: $size" >> report.log
    done
    
    echo -n "MAC Adresi: " >> report.log
    ifconfig | grep "ether " | head -n 1 | awk '{print $2}' >> report.log

else
    echo "Sistem: Diger (Linux)" >> report.log
    
    echo -n "Islemci Bilgisi: " >> report.log
    lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo "RAM Detaylari:" >> report.log
    dmidecode --type memory 2>/dev/null | grep -E "Manufacturer:|Part Number:|Serial Number:|Size:" | grep -v "No Module" | awk -F': ' '{print $2}' | paste - - - - | while read -r size type man part ser; do
        echo "  -> Uretici: $man | Parca No: $part | Seri No: $ser | Kapasite: $size" >> report.log
    done
    
    echo -n "Anakart Bilgisi (Uretici / Model / SeriNo): " >> report.log
    vendor=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null || echo "Bilinmiyor")
    name=$(cat /sys/class/dmi/id/board_name 2>/dev/null || echo "Bilinmiyor")
    serial=$(cat /sys/class/dmi/id/board_serial 2>/dev/null || echo "Bilinmiyor")
    echo "$vendor / $name / $serial" >> report.log
    
    echo -n "Anakart UUID: " >> report.log
    cat /sys/class/dmi/id/product_uuid 2>/dev/null || echo "Erisim Yok" >> report.log
    
    echo "Disk Detaylari:" >> report.log
    lsblk -d -o MODEL,SERIAL,SIZE,NAME 2>/dev/null | tail -n +2 | while read -r model serial size name; do
        echo "  -> Model: $model | Seri No: $serial | Kapasite: $size" >> report.log
    done
    
    echo -n "MAC Adresi: " >> report.log
    ip link | grep "link/ether" | head -n 1 | awk '{print $2}' >> report.log
fi

echo "--------------------------------" >> report.log
echo "Donanim bilgileri report.log dosyasina kaydedildi."

PAROLA="MYO+202"

echo "Dosya gpg ile sifreleniyor..."
gpg --batch --yes --passphrase "$PAROLA" --cipher-algo AES256 --output report.log.gpg --symmetric report.log

rm -f report.log
echo "Orijinal report.log dosyasi temizlendi."
echo "Islem bitti."

read -p "Kapatmak icin Enter tusuna basin..."