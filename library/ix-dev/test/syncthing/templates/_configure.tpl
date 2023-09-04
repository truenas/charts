{{- define "syncthing.configure" -}}
{{/*
  https://docs.syncthing.net/users/config.html
  Note: Configuration in the above link does not match the subcommands of the cli
  To get the correct subcommands, run `syncthing cli config <category>`
  It will print all the available subcommands for that category
  "Knobs" are exposed under Values.syncthingConfig, We can exposed those to questions.yaml if we want
 */}}
configmap:
  syncthing-configure:
    enabled: true
    data:
      configure.sh: |
        #!/bin/sh
        set -e
        configDir=/var/syncthing/config

        # Make sure the file exists
        until [ -f "$configDir/config.xml" ]; do
          sleep 2
        done

        # Check the API is running
        until curl --silent --output /dev/null http://localhost:{{ .Values.syncthingNetwork.webPort }}/rest/noauth/health; do
          sleep 2
        done

        function setConfig() {
          syncthing cli --home "$configDir" config $@
        }

        # Now we can use the syncthing cli (wrapper around the API) to set the defaults.
        # Keep in mind that all the below values are not enforced, user can change them
        # while the app is running, but will be re-applied on restart.

        # Category "options" is more like "general" or "global" settings.
        setConfig options announce-lanaddresses set -- {{ ternary "1" "0" .Values.syncthingConfig.announceLANAddresses | quote }}
        setConfig options global-ann-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.globalDiscovery | quote }}
        setConfig options local-ann-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.localDiscovery | quote }}
        setConfig options natenabled set -- {{ ternary "1" "0" .Values.syncthingConfig.natTraversal | quote }}
        setConfig options relays-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.relaying | quote }}
        setConfig options uraccepted set -- {{ ternary "1" "-1" .Values.syncthingConfig.telemetry | quote }}
        setConfig options auto-upgrade-intervalh set -- "0"

        # Category "defaults/folder" contains the default settings for new folders.
        setConfig defaults folder xattr-filter max-total-size set -- 10485760
        setConfig defaults folder xattr-filter max-single-entry-size set -- 2097152
        setConfig defaults folder send-ownership set -- 1
        setConfig defaults folder sync-ownership set -- 1
        setConfig defaults folder send-xattrs set -- 1
        setConfig defaults folder sync-xattrs set -- 1
        setConfig defaults folder ignore-perms set -- 1
  syncthing-truenas-logo:
    enabled: true
    data:
      logo-horizontal.svg: |
        <svg id="TN_Scale_RGB" data-name="TN Scale RGB" xmlns="http://www.w3.org/2000/svg" width="129.29" height="25.448" viewBox="0 0 129.29 25.448">
          <g id="Logomark">
            <g id="logoMark-2" data-name="logoMark">
              <path id="logoMark_PathItem_" data-name="logoMark &lt;PathItem&gt;" d="M48.576,16.032l-3.163,1.827-3.174-1.832L45.406,14.2Z" transform="translate(-27.484 -9.24)" fill="#aeadae"/>
              <path id="logoMark_PathItem_2" data-name="logoMark &lt;PathItem&gt;" d="M60.539,4.1,57.368,5.929l-3.92-2.264V0Z" transform="translate(-34.778 -0.001)" fill="#0095d5"/>
              <path id="logoMark_PathItem_3" data-name="logoMark &lt;PathItem&gt;" d="M35.956,0V3.663L32.04,5.922,28.868,4.091Z" transform="translate(-18.784)" fill="#31beec"/>
              <path id="logoMark_PathItem_4" data-name="logoMark &lt;PathItem&gt;" d="M7.839,39.056,0,34.53l0-3.661L3.534,32.91l.029.016,4.274,2.468Z" transform="translate(0 -20.086)" fill="#0095d5"/>
              <path id="logoMark_PathItem_5" data-name="logoMark &lt;PathItem&gt;" d="M21.853,31.471,18.686,33.3l-3.173-1.832,3.169-1.828Z" transform="translate(-10.094 -19.286)" fill="#aeadae"/>
              <path id="logoMark_PathItem_6" data-name="logoMark &lt;PathItem&gt;" d="M9.226,19.115,5.314,21.372,2.142,19.541l7.083-4.088Z" transform="translate(-1.394 -10.055)" fill="#31beec"/>
              <path id="logoMark_PathItem_7" data-name="logoMark &lt;PathItem&gt;" d="M33.826,19.547l-3.165,1.828-3.919-2.264V15.457l3.522,2.033.028.016Z" transform="translate(-17.4 -10.058)" fill="#0095d5"/>
              <path id="logoMark_PathItem_8" data-name="logoMark &lt;PathItem&gt;" d="M61.308,46.429v3.662L60.6,50.5l-7.132,4.118V50.957l3.96-2.287,1.5-.865Z" transform="translate(-34.791 -30.211)" fill="#31beec"/>
              <path id="logoMark_PathItem_9" data-name="logoMark &lt;PathItem&gt;" d="M48.583,47.023l-3.17,1.831-3.173-1.832,3.173-1.831Z" transform="translate(-27.484 -29.405)" fill="#aeadae"/>
              <path id="logoMark_PathItem_10" data-name="logoMark &lt;PathItem&gt;" d="M35.963,30.993v3.663l-.715.413L32.04,36.919,32,36.9l-3.137-1.812,3.207-1.851,1.5-.865L35.956,31Z" transform="translate(-18.784 -20.167)" fill="#31beec"/>
              <path id="logoMark_PathItem_11" data-name="logoMark &lt;PathItem&gt;" d="M34.568,50.957v3.66L27.44,50.5l-.715-.413,0-3.661.006,0,2.382,1.375,1.146.661.029.017.323.186Z" transform="translate(-17.389 -30.211)" fill="#0095d5"/>
              <path id="logoMark_PathItem_12" data-name="logoMark &lt;PathItem&gt;" d="M88.058,30.871v3.663l-7.84,4.526V35.4Z" transform="translate(-52.197 -20.087)" fill="#31beec"/>
              <path id="logoMark_PathItem_13" data-name="logoMark &lt;PathItem&gt;" d="M75.333,31.468,72.162,33.3l-3.173-1.833,3.173-1.83Z" transform="translate(-44.89 -19.284)" fill="#aeadae"/>
              <path id="logoMark_PathItem_14" data-name="logoMark &lt;PathItem&gt;" d="M87.309,19.532l-3.172,1.833L80.218,19.1V15.438Z" transform="translate(-52.197 -10.045)" fill="#0095d5"/>
              <path id="logoMark_PathItem_15" data-name="logoMark &lt;PathItem&gt;" d="M62.713,15.435V19.1L58.79,21.362,55.618,19.53Z" transform="translate(-36.19 -10.043)" fill="#31beec"/>
              <path id="logoMark_PathItem_16" data-name="logoMark &lt;PathItem&gt;" d="M60.563,35.09,57.432,36.9h0l-3.956-2.284V31l2.38,1.374,1.5.865Z" transform="translate(-34.795 -20.169)" fill="#0095d5"/>
            </g>
          </g>
          <g id="full-rgb" transform="translate(39.123)">
            <g id="type" transform="translate(0 0)">
              <path id="type_CompoundPathItem_" data-name="type &lt;CompoundPathItem&gt;" d="M12.7.646V2.6H7.426V17.958H5.269V2.6H0V.646Z" transform="translate(0 -0.421)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_2" data-name="type &lt;CompoundPathItem&gt;" d="M43.14,16.629a2.383,2.383,0,0,0-2.107-1.054,2.728,2.728,0,0,0-2.684,3.036v7.853H36.341V13.919h2.008v1.23a3.043,3.043,0,0,1,2.91-1.43,3.989,3.989,0,0,1,3.588,1.706Z" transform="translate(-23.647 -8.926)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_3" data-name="type &lt;CompoundPathItem&gt;" d="M74.576,26.838H72.568V25.609c-.627.953-1.5,1.43-3.361,1.43-2.684,0-4.566-1.405-4.566-4.918V14.293h2.007v7.8c0,2.534,1.38,3.086,2.86,3.086a2.923,2.923,0,0,0,3.061-3.061V14.293h2.008Z" transform="translate(-42.061 -9.3)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_4" data-name="type &lt;CompoundPathItem&gt;" d="M108.944,24.557c-.878,1.531-2.208,2.108-4.39,2.108-3.362,0-5.37-2.183-5.37-5.67V19.338c0-3.562,1.681-5.62,4.968-5.62,3.312,0,4.968,2.032,4.968,5.62v1.3h-7.928v.351c0,2.158,1.029,3.863,3.211,3.863,1.631,0,2.459-.476,2.985-1.4Zm-7.753-5.67h5.9c-.1-2.107-1.028-3.362-2.936-3.362C102.22,15.525,101.316,16.8,101.191,18.887Z" transform="translate(-64.538 -8.926)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_5" data-name="type &lt;CompoundPathItem&gt;" d="M149.265.646V17.958H146.68L139.63,6.191V17.958h-2.81V.646h2.509l7.126,11.917V.646Z" transform="translate(-89.027 -0.421)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_6" data-name="type &lt;CompoundPathItem&gt;" d="M178.044,17.958,184.066.646h2.76l6.021,17.312h-3.086l-1.18-3.588h-6.247l-1.179,3.588Zm5.093-6.1h4.617l-2.308-7Z" transform="translate(-115.851 -0.421)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_7" data-name="type &lt;CompoundPathItem&gt;" d="M232.654,4.416a4.038,4.038,0,0,0-3.738-1.882c-1.781,0-2.835.8-2.835,2.258,0,1.656,1.3,2.308,3.714,2.835,3.487.753,5.294,2.057,5.294,5.168,0,2.584-1.732,4.968-5.9,4.968-2.96,0-5.043-.9-6.473-2.835L225,13.347a4.634,4.634,0,0,0,4.039,1.882c2.384,0,3.136-1.054,3.136-2.308,0-1.38-.777-2.233-3.788-2.885-3.337-.7-5.219-2.308-5.219-5.244,0-2.609,1.706-4.792,5.771-4.792,2.76,0,4.692.928,5.921,2.835Z" transform="translate(-144.92 0)" fill="#0095d5"/>
              <path id="type_CompoundPathItem_8" data-name="type &lt;CompoundPathItem&gt;" d="M16.888,61.246a1.006,1.006,0,0,0-.932-.469c-.444,0-.707.2-.707.563,0,.413.325.576.926.707.869.188,1.32.513,1.32,1.289,0,.644-.432,1.238-1.47,1.238a1.846,1.846,0,0,1-1.614-.707l.569-.394a1.156,1.156,0,0,0,1.007.469c.594,0,.782-.263.782-.575,0-.344-.194-.557-.944-.72-.832-.175-1.3-.575-1.3-1.307,0-.651.425-1.195,1.439-1.195a1.61,1.61,0,0,1,1.476.707Z" transform="translate(-9.377 -39.132)" fill="#aeadae"/>
              <path id="type_CompoundPathItem_9" data-name="type &lt;CompoundPathItem&gt;" d="M29.1,61.551a.821.821,0,0,0-.869-.763c-.575,0-.888.375-.888,1.307v.55c0,.919.313,1.307.888,1.307a.81.81,0,0,0,.869-.763H29.8a1.445,1.445,0,0,1-1.564,1.395c-.963,0-1.614-.582-1.614-1.939V62.1c0-1.357.65-1.939,1.614-1.939a1.47,1.47,0,0,1,1.57,1.395Z" transform="translate(-17.321 -39.143)" fill="#aeadae"/>
              <path id="type_CompoundPathItem_10" data-name="type &lt;CompoundPathItem&gt;" d="M38.021,64.633l1.5-4.316h.688l1.5,4.316h-.769l-.294-.894H39.091l-.294.894Zm1.27-1.52h1.151l-.575-1.745Z" transform="translate(-24.74 -39.248)" fill="#aeadae"/>
              <path id="type_CompoundPathItem_11" data-name="type &lt;CompoundPathItem&gt;" d="M52.512,64.008h1.92v.626H51.787V60.317h.726Z" transform="translate(-33.697 -39.248)" fill="#aeadae"/>
              <path id="type_CompoundPathItem_12" data-name="type &lt;CompoundPathItem&gt;" d="M65.226,60.317v.632h-1.92v1.138h1.733v.625H63.306v1.295h1.92v.626H62.581V60.317Z" transform="translate(-40.72 -39.248)" fill="#aeadae"/>
            </g>
          </g>
        </svg>
{{- end -}}
