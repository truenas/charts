{{- define "diskover.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
  {{- $elasticsearch := printf "%s-elasticsearch" $fullname }}

{{- $esPassword := randAlphaNum 32 }}
secret:
  diskover-secret:
    enabled: true
    data:
      es-password: {{ $esPassword }}
configmap:
  diskover-config:
    enabled: true
    data:
      .default_crawler.sh: |-
        #!/bin/sh
        while true; do
            # this condition wait for the script to copy into the container .
            if test -f "$1"; then
                # Empty folders don't generate indices . if folder is empty a default file is generated
                if ! [ "$(ls -A $2)" ]; then
                    echo "Dummy file created as empty dirs are rejected" > $2/diskover_test.txt;
                fi
                python3 $1 $2/;
                break;
            fi
            sleep 5
        done
      Constants.php: |
        <?php
            namespace diskover;
            class Constants {
                const TIMEZONE = '{{ .Values.TZ }}';
                const ES_HOST = '{{ $elasticsearch }}';
                const ES_PORT = 9200;
                const ES_USER = 'elastic';
                const ES_PASS = '{{ $esPassword }}';
                // if your Elasticsearch cluster uses HTTP TLS/SSL, set ES_HTTPS to TRUE
                // override with env var ES_HTTPS
                const ES_HTTPS = FALSE;
                // login auth for diskover-web
                const LOGIN_REQUIRED = TRUE;
                // default username and password to login
                // the password is no longer used after first login, a hashed password gets stored in separate sqlite db
                const USER = '{{ .Values.diskoverConfig.username }}';
                const PASS = '{{ .Values.diskoverConfig.password }}';
                // default results per search page
                const SEARCH_RESULTS = 50;
                // default size field (size, size_du) to use for sizes on file tree and charts
                const SIZE_FIELD = 'size';
                // default file types, used by quick search (file type) and dashboard file type usage chart
                // additional extensions can be added/removed from each file types list
                const FILE_TYPES = [
                    'docs' => ['doc', 'docx', 'odt', 'pdf', 'tex', 'wpd', 'wks', 'txt', 'rtf', 'key', 'odp', 'pps', 'ppt', 'pptx', 'ods', 'xls', 'xlsm', 'xlsx'],
                    'images' => ['ai', 'bmp', 'gif', 'ico', 'jpeg', 'jpg', 'png', 'ps', 'psd', 'psp', 'svg', 'tif', 'tiff', 'exr', 'tga'],
                    'video' => ['3g2', '3gp', 'avi', 'flv', 'h264', 'm4v', 'mkv', 'qt', 'mov', 'mp4', 'mpg', 'mpeg', 'rm', 'swf', 'vob', 'wmv', 'ogg', 'ogv', 'webm'],
                    'audio' => ['au', 'aif', 'aiff', 'cda', 'mid', 'midi', 'mp3', 'm4a', 'mpa', 'ogg', 'wav', 'wma', 'wpl'],
                    'apps' => ['apk', 'exe', 'bat', 'bin', 'cgi', 'pl', 'gadget', 'com', 'jar', 'msi', 'py', 'wsf'],
                    'programming' => ['c', 'cgi', 'pl', 'class', 'cpp', 'cs', 'h', 'java', 'php', 'py', 'sh', 'swift', 'vb'],
                    'internet' => ['asp', 'aspx', 'cer', 'cfm', 'cgi', 'pl', 'css', 'htm', 'html', 'js', 'jsp', 'part', 'php', 'py', 'rss', 'xhtml'],
                    'system' => ['bak', 'cab', 'cfg', 'cpl', 'cur', 'dll', 'dmp', 'drv', 'icns', 'ico', 'ini', 'lnk', 'msi', 'sys', 'tmp', 'vdi', 'raw'],
                    'data' => ['csv', 'dat', 'db', 'dbf', 'log', 'mdb', 'sav', 'sql', 'tar', 'xml'],
                    'disc' => ['bin', 'dmg', 'iso', 'toast', 'vcd', 'img'],
                    'compressed' => ['7z', 'arj', 'deb', 'pkg', 'rar', 'rpm', 'tar', 'gz', 'z', 'zip'],
                    'trash' => ['old', 'trash', 'tmp', 'temp', 'junk', 'recycle', 'delete', 'deleteme', 'clean', 'remove']
                ];
                // extra fields for search results and view file/dir info pages
                // key is description for field and value is ES field name
                // Example:
                //const EXTRA_FIELDS = [
                //    'Date Changed' => 'ctime'
                //];
                const EXTRA_FIELDS = [];
                // Maximum number of indices to load by default, indices are loaded in order by creation date
                // setting this too high can cause slow logins and other timeout issues
                // This setting can bo overridden on indices page per user and stored in maxindex cookie
                // If MAX_INDEX is set higher than maxindex browser cookie, the cookie will be set to this value
                const MAX_INDEX = 250;
                // time in seconds for index info to be cached, clicking reload indices forces update
                const INDEXINFO_CACHETIME = 600;
                // time in seconds to check Elasticsearch for new index info
                const NEWINDEX_CHECKTIME = 10;
                // sqlite database file path
                const DATABASE = '../diskoverdb.sqlite3';
            }
      config.yaml: |
        # diskover default/sample config file
        #
        # default search paths for config
        # macOS: ~/.config/diskover and ~/Library/Application Support/diskover
        # Other Unix: ~/.config/diskover and /etc/diskover
        # Windows: %APPDATA%\diskover where the APPDATA environment variable falls back to %HOME%\AppData\Roaming if undefined
        #
        appName: diskover
        logLevel: INFO
        logToFile: False
        logDirectory: /tmp/

        diskover:
            # max number of crawl threads
            # a thread is created up to maxthreads for each directory at level 1 of tree dir arg
            # set to a number or leave blank to auto set based on number of cpus
            #maxthreads: 20
            maxthreads:
            # block size used for du size
            blocksize: 512
            excludes:
                # directory names and absolute paths you want to exclude from crawl
                # directory excludes uses python re.search for string search (regex)
                # directory excludes are case-sensitive
                # Examples: .* or .backup or .backup* or /dir/dirname
                # to exclude none use empty list []
                dirs: [".*", ".snapshot", ".Snapshot", "~snapshot", "~Snapshot", ".zfs"]
                #dirs: []
                # files you want to exclude from crawl
                # can include wildcards (.*, *.doc or NULLEXT for files with no extension)
                # file names are case-sensitive, extensions are not
                files: [".*", "Thumbs.db", ".DS_Store", "._.DS_Store", ".localized", "desktop.ini"]
                #files: []
                # exclude empty 0 byte files, set to True to exclude empty files or False to not exclude
                emptyfiles: True
                # exclude empty dirs, set to True to exclude empty dirs or False to not exclude
                emptydirs: True
                # exclude files smaller than min size in bytes
                minfilesize: 1
                #minfilesize: 512
                # exclude files modified less than x days ago
                minmtime: 0
                #minmtime: 30
                # exclude files modified more than x days ago
                maxmtime: 36500
                # exclude files changed less than x days ago
                minctime: 0
                # exclude files changed more than x days ago
                maxctime: 36500
                # exclude files accessed less than x days ago
                minatime: 0
                # exclude files accessed more than x days ago
                maxatime: 36500
            includes:
                # directory names and absolute paths you want to include (whitelist), case-sensitive,
                # to include none use empty list []
                #dirs: [".recycle"]
                dirs: []
                # files you want to include (whitelist), case-sensitive
                files: []
            ownersgroups:
                # control how owner (username) and group fields are stored for file and directory docs
                # store uid and gid's instead of trying to get owner and group names
                uidgidonly: False
                # owner/group names contain domain name set to True
                domain: False
                # character separator used on cifs/nfs mounts to separte user/group and domain name, usually \ or @
                domainsep: \
                # if domain name comes first before character separator, set this to True, otherwise False
                domainfirst: True
                # when indexing owner and group fields, keep the domain name
                keepdomain: False
            replacepaths:
                # translate path names set to True to enable or False to disable.
                # Set to True if crawling in Windows to replace drive letters and \ with /
                replace: False
                #from: /mnt/
                #to:  /vols/
                from:
                to:
            plugins:
                # set to True to enable all plugins or False to disable all plugins
                enable: False
                # list of plugins (by name) to use for directories
                dirs: ['unixperms']
                # list of plugins (by name) to use for files
                files: ['unixperms']
            other:
                # restore atime/mtime for files and dirs during crawl
                # set to True or False, default False (useful for cifs which does not work with noatime mount option)
                # for nfs, it's preferable to use mount options ro,noatime,nodiratime
                restoretimes: False

        databases:
            elasticsearch:
                host: '{{ $elasticsearch }}'
                port: 9200
                user: 'elastic'
                password: '{{ $esPassword }}'
                # set https to True if using HTTP TLS/SSL or False if using http
                # for AWS ES, you will most likely want to set this to True
                # override with env var ES_HTTPS
                https: False
                # compress http data
                # for AWS ES, you will most likely want to set this to True
                httpcompress: False
                # timeout for connection to ES (default is 10)
                timeout: 30
                # number of connections kept open to ES when crawling (default is 10)
                maxsize: 20
                # max retries for ES operations (default is 0)
                maxretries: 10
                # wait for at least yellow status before bulk uploading (default is False), set to True if you want to wait
                wait: False
                # chunk size for ES bulk operations (default is 500)
                chunksize: 1000
                # the below settings are to optimize ES for crawling
                # index refresh interval (default is 1s), set to -1 to disable refresh during crawl (fastest performance but no index searches), after crawl is set back to 1s
                indexrefresh: 30s
                # transaction log flush threshold size (default 512mb)
                translogsize: 1gb
                # transaction log sync interval time (default 5s)
                translogsyncint: 30s
                # search scroll size (default 100 docs)
                scrollsize: 1000
{{- end -}}
