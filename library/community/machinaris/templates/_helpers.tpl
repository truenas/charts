{{- define "machinaris.portmap" -}}
  {{- $ports := (dict
                          "machinaris"
                              (dict "apiPort" 8927
                                    "webPort" 8926
                                    "workerPort" 8947)
                          "apple"
                              (dict "farmerPort" 26667
                                    "netPort" 266666
                                    "workerPort" 8947)
                          "ballcoin"
                              (dict "farmerPort" 38891
                                    "netPort" 38888
                                    "workerPort" 8957)
                          "greenbtc"
                              (dict "farmerPort" 23332
                                    "netPort" 23333
                                    "workerPort" 8955)
  ) -}}
  {{- $ports | toJson -}}
{{- end -}}
