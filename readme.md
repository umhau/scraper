# scraper

interface is a folder that we drop text files into. text files are in the format

    /output/dir example.com

Where the output dir is the location where the url should be saved to (with all its resources).

## usage

To run the scraper, it's best to put it in a while loop, just in case it crashes. It uses its own internal while loop, but is set up to exit in case of errors.

    while : ; do scraper ; done

The scraper expects requested urls to be dropped into `/var/lib/scraper/pool`. Filenames are arbitrary, but should be unique.

