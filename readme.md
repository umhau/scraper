# scraper

interface is a folder that we drop text files into. text files are in the format

    /output/dir example.com

Where the output dir is the location where the url should be saved to (with all its resources).

## usage

Install the scraper with

    su
    ./install.sh [quick]

Scraper is self-sufficient; if the network stops working, it's likely because the vpn needs to be re-upped. 

    scraper

It's best to put it in a while loop just in case it crashes.

    while : ; do scraper ; done

The scraper expects requested urls to be dropped into `/var/lib/scraper/pool`. Filenames are arbitrary, but should be unique.

## network usage

To interact over the network, mount `/var/lib/scraper/' with sshfs, at the same location.

    scraperhost=192.168.1.7
    mkdir -pv /var/lib/scraper
    chmod 777 /var/lib/scraper
    sshfs -o allow_root,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 $scraperhost:/var/lib/scraper /var/lib/scraper

With these sshfs options, the connection will recover even after extended disconnections (15 min). Also note this assumes common usernames across my systems.

Create a directory for the program accessing the scraper

    prog=submarine
    mkdir -pv /var/lib/scraper/dump/$prog
    chmod -R 777 /var/lib/scraper/dump

Now urls can be dropped into `/var/lib/scraper/pool`. The url files should specify `/var/lib/scraper/dump/$prog/` as the output directory, as this absolute path will be accessible to both machines.

Network speed, note, is not a bottleneck compared to the (intentional) latency of the downloads themselves.

## failure detection

The scraper currently has custom html parsing to detect if an amazon page access was blocked; this should be updated with each additional website where blockage should be detected. 

(The significance of blockage detection is to change the VPN at each block.)
