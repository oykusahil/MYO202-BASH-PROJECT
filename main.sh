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
    wmic cpu get Name | tail -n +2 | tr -d '\r' | grep -v '^$' >> report.log
    
    echo -n "RAM Bilgisi (Bayt): " >> report.log
    wmic computersystem get TotalPhysicalMemory | tail -n +2 | tr -d '\r' | grep -v '^$' >> report.log
    
    echo -n "Anakart Bilgisi: " >> report.log
    wmic baseboard get Product | tail -n +2 | tr -d '\r' | grep -v '^$' >> report.log
    
<<<<<<< HEAD
    echo -n "Disk UUID: " >> report.log
    wmic diskdrive get SerialNumber | tail -n +2 | tr -d '\r' | grep -v '^$' >> report.log
=======
    echo "Disk Detaylari:" >> report.log
    wmic diskdrive get Model, SerialNumber, Size | tail -n +2 | tr -d '\r' | grep -v '^$' | while read -r line; do
        size=$(echo "$line" | awk '{print $failed; print $NF}') 
        d_model=$(echo "$line" | awk '{$NF=""; $(NF-1)=""; print $0}' | sed 's/[[:space:]]*$//')
        d_serial=$(echo "$line" | awk '{print $(NF-1)}')
        d_size=$(echo "$line" | awk '{print $NF}')
        echo "  -> Model: $d_model | Seri No: $d_serial | Kapasite: $((d_size / 1024 / 1024 / 1024)) GB ($d_size Byte)" >> report.log
    done
>>>>>>> 4d49b4b (update)
    
    echo -n "MAC Adresi: " >> report.log
    getmac | grep -i "tcpip" | head -n 1 | awk '{print $1}' | tr -d '\r' >> report.log

elif [[ "$SISTEM" == "Darwin" ]]; then
    echo "Sistem: Macbook (macOS)" >> report.log
    
    echo -n "Islemci Bilgisi: " >> report.log
    system_profiler SPHardwareDataType | grep "Processor Name" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo -n "RAM Bilgisi: " >> report.log
    system_profiler SPHardwareDataType | grep "Memory" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo -n "Anakart Bilgisi: " >> report.log
    system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo -n "Disk UUID: " >> report.log
    system_profiler SPHardwareDataType | grep "Hardware UUID" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo -n "MAC Adresi: " >> report.log
    ifconfig | grep "ether " | head -n 1 | awk '{print $2}' >> report.log

else
    echo "Sistem: Diger (Linux)" >> report.log
    
    echo -n "Islemci Bilgisi: " >> report.log
    lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^ //' >> report.log
    
    echo -n "RAM Bilgisi: " >> report.log
    free -h | grep "Mem:" | awk '{print $2}' >> report.log
    
    echo -n "Anakart Bilgisi: " >> report.log
    cat /sys/class/dmi/id/board_name 2>/dev/null || echo "Erisim Yok" >> report.log
    
    echo -n "Disk UUID: " >> report.log
    cat /sys/class/dmi/id/product_uuid 2>/dev/null || echo "Erisim Yok" >> report.log
    
    echo -n "MAC Adresi: " >> report.log
    ip link | grep "link/ether" | head -n 1 | awk '{print $2}' >> report.log
fi

echo "--------------------------------" >> report.log
echo "Donanim bilgileri report.log dosyasina kaydedildi."

echo -n "Lutfen sifreyi giriniz (MYO+202): "
read -s PAROLA
echo ""

echo "Dosya gpg ile sifreleniyor..."
echo "$PAROLA" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 --output report.log.gpg report.log

rm -f report.log
echo "Orijinal report.log dosyasi temizlendi."
echo "Islem bitti."
read -p "Kapatmak icin Enter tusuna basin..."
