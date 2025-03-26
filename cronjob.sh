#!/bin/bash

# Tạo cron job để khởi động lại hệ thống mỗi 3 giờ
(crontab -l 2>/dev/null; echo "0 */3 * * * /sbin/shutdown -r now") | crontab -
