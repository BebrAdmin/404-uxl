# 404 Updater Xray List

Install and update lists with one Linux command:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/BebrAdmin/404-uxl/main/updater-xray-list.sh)
```

## What the script does
Downloads and keeps up to date a set of .dat files for Xray:
- geosite_v2fly.dat / geoip_v2fly.dat
- geosite_ru.dat / geoip_ru.dat (runetfreedom)
- geosite_antifilter.dat / geoip_antifilter.dat (NetworkKeeper)
- geosite_refilter.dat / geoip_refilter.dat (Re-filter)
- zapret.dat (ru_gov_zapret)

Target directory: /opt/remnanode/xray-list  
File mode: 0644

## Docker Compose (volumes)
Add to your Xray/V2Ray service:
```yaml
    volumes:
      - /opt/remnanode/xray-list/geosite_v2fly.dat:/usr/local/bin/geosite_v2fly.dat
      - /opt/remnanode/xray-list/geoip_v2fly.dat:/usr/local/bin/geoip_v2fly.dat
      - /opt/remnanode/xray-list/geosite_ru.dat:/usr/local/bin/geosite_ru.dat
      - /opt/remnanode/xray-list/geoip_ru.dat:/usr/local/bin/geoip_ru.dat
      - /opt/remnanode/xray-list/geosite_antifilter.dat:/usr/local/bin/geosite_antifilter.dat
      - /opt/remnanode/xray-list/geoip_antifilter.dat:/usr/local/bin/geoip_antifilter.dat
      - /opt/remnanode/xray-list/geosite_refilter.dat:/usr/local/bin/geosite_refilter.dat
      - /opt/remnanode/xray-list/geoip_refilter.dat:/usr/local/bin/geoip_refilter.dat
      - /opt/remnanode/xray-list/zapret.dat:/usr/local/bin/zapret.dat
```