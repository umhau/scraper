import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import pyautogui
import time
import os
import glob
import sys

# output format: ./output_folder/page*, where 'page' is the base name with any number of possible
# extensions. this is actually a decent general-purpose downloader. Note that complete webpage 
# downloads will have two items in the /.output_folder - the page.html, and ./page/ which is a 
# folder containing all the webpage resources - images, css, javascript, etc.
# 
# python3 ./selenium.py /tmp/outdir "$useragent" "$windowsize" "/tmp/userdatadir" "$url"

timeout         = 300
check_interval  = 2
accept_language = "en-US,en;q=0.9"
page_load_wait  = 10

output_dir      = sys.argv[1]
user_agent      = sys.argv[2]
window_size     = sys.argv[3]
user_data_dir   = sys.argv[4]
url             = sys.argv[5]

options = Options()

options.add_argument(f"user-agent={user_agent}")    
options.add_argument(f"--window-size={window_size}")
options.add_argument(f"--user-data-dir={user_data_dir}")

options.page_load_strategy = 'eager'
options.add_argument("--disable-webgl")
options.add_argument(f"accept-language={accept_language}")

# Disable explicit automation flags
options.add_argument("--disable-blink-features")
options.add_argument("--disable-blink-features=AutomationControlled")

# Debugging options (uncomment as needed)
# options.add_argument("--no-sandbox")
# options.add_argument("--headless")
# options.add_argument("--disable-dev-shm-usage")         
# options.add_argument("--remote-debugging-port=9222")
options.add_argument("--disable-extensions") 
options.add_argument("--disable-gpu") 
# options.add_argument("start-maximized") 
# options.add_argument("disable-infobars")

print("initializing chrome webdriver")
driver = webdriver.Chrome(options=options)

try:
    print(f"opening url {url}")
    driver.get(url)

    print(f"waiting {page_load_wait} seconds for page load")
    driver.implicitly_wait(page_load_wait)

    # open save-as page & wait for dialog to appear
    print("saving web page with pyautogui")
    pyautogui.hotkey('ctrl', 's')
    time.sleep(2)

    # type in the output folder path, wait for typing to finish, then press enter to save
    print("typing full output path")
    pyautogui.typewrite(output_dir + '/page')
    time.sleep(1)
    pyautogui.hotkey('enter')

    # try to download the website - but timeout if it takes too long
    print(f"waiting for download to finish - timing out in {timeout} seconds")
    download_completed = False
    start_time = time.time()

    while time.time() - start_time < timeout:
        print("checking if download completed...")

        if glob.glob(os.path.join(output_dir, "page.*")):
            download_completed = True
            print("download completed")
            break

        time.sleep(check_interval)

    if not download_completed:
        print("Download timed out.")

finally:
    driver.quit()
    print("finished trying")
