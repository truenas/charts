{{- define "minecraft.configuration" -}}
{{- include "minecraft.validation" $ }}
configmap:
  minecraft-config:
    enabled: true
    data:
      {{/*
      There is no GUI in the container,
      but some old versions think that there is
      */}}
      GUI: "FALSE"
      EULA: {{ .Values.mcConfig.eula | quote | upper }}
      ENABLE_RCON: {{ .Values.mcConfig.enableRcon | quote | upper }}
      SERVER_PORT: {{ .Values.mcNetwork.serverPort | quote }}
      {{ if .Values.mcConfig.enableRcon }}
      RCON_PORT: {{ .Values.mcNetwork.rconPort | quote }}
      RCON_PASSWORD: {{ .Values.mcConfig.rconPassword | quote }}
      {{ end }}
      VERSION: {{ .Values.mcConfig.version | quote }}
      TYPE: {{ .Values.mcConfig.type | quote }}
      {{ with .Values.mcConfig.seed }}
      SEED: {{ . | quote }}
      {{ end }}
      MOTD: {{ .Values.mcConfig.motd | quote }}
      DIFFICULTY: {{ .Values.mcConfig.difficulty | quote }}
      SERVER_NAME: {{ .Values.mcConfig.serverName | quote }}
      MAX_PLAYERS: {{ .Values.mcConfig.maxPlayers | quote }}
      MAX_WORLD_SIZE: {{ .Values.mcConfig.maxWorldSize | quote }}
      ALLOW_NETHER: {{ .Values.mcConfig.allowNether | quote | upper }}
      ANNOUNCE_PLAYER_ACHIEVEMENTS: {{ .Values.mcConfig.announcePlayerAchievements | quote | upper }}
      ENABLE_COMMAND_BLOCK: {{ .Values.mcConfig.enableCommandBlock | quote | upper }}
      FORCE_GAMEMODE: {{ .Values.mcConfig.forceGameMode | quote | upper }}
      GENERATE_STRUCTURES: {{ .Values.mcConfig.generateStructures | quote | upper }}
      HARDCORE: {{ .Values.mcConfig.hardcore | quote | upper }}
      MAX_BUILD_HEIGHT: {{ .Values.mcConfig.maxBuildHeight | quote }}
      SPAWN_ANIMALS: {{ .Values.mcConfig.spawnAnimals | quote | upper }}
      SPAWN_MONSTERS: {{ .Values.mcConfig.spawnMonsters | quote | upper }}
      SPAWN_NPCS: {{ .Values.mcConfig.spawnNpcs | quote | upper }}
      SPAWN_PROTECTION: {{ .Values.mcConfig.spawnProtection | quote }}
      VIEW_DISTANCE: {{ .Values.mcConfig.viewDistance | quote }}
      PVP: {{ .Values.mcConfig.pvp | quote | upper }}
      LEVEL_TYPE: {{ .Values.mcConfig.levelType | quote }}
      ALLOW_FLIGHT: {{ .Values.mcConfig.allowFlight | quote | upper }}
      ONLINE_MODE: {{ .Values.mcConfig.onlineMode | quote | upper }}
      MAX_TICK_TIME: {{ .Values.mcConfig.maxTickTime | quote }}
      {{ with .Values.mcConfig.ops }}
      OPS: {{ join "," . | quote }}
      {{ end }}
      {{ with .Values.mcConfig.whitelist }}
      WHITELIST: {{ join "," . | quote }}
      {{ end }}
{{- end -}}

{{- define "minecraft.validation" -}}
  {{- if not .Values.mcConfig.eula -}}
    {{- fail "Minecraft - You have to accept EULA" -}}
  {{- end -}}

  {{- $types := (list "VANILLA" "SPIGOT" "BUKKIT" "PAPER" "FOLIA"
                      "FABRIC" "FORGE" "NEOFORGE" "AUTO_CURSEFORGE" "MODRINTH"
                      "FTBA" "PUFFERFISH" "PURPUR" "QUILT" "MAGMA"
                      "MAGMA_MAINTAINED" "KETTING" "MOHIST" "CATSERVER" "SPONGEVANILLA"
                      "LIMBO" "CRUCIBLE" "CUSTOM") -}}
  {{- if not (mustHas .Values.mcConfig.type $types) -}}
    {{- fail (printf "Minecraft - Expected [Type] to be one of [%s], but got [%s]" (join ", " $types) .Values.mcConfig.type) -}}
  {{- end -}}

  {{- $difficulties := (list "peaceful" "easy" "normal" "hard") -}}
  {{- if not (mustHas .Values.mcConfig.difficulty $difficulties) -}}
    {{- fail (printf "Minecraft - Expected [Difficulty] to be one of [%s], but got [%s]" (join ", " $difficulties) .Values.mcConfig.difficulty) -}}
  {{- end -}}

  {{- $modes := (list "creative" "survival" "adventure" "spectator") -}}
  {{- if not (mustHas .Values.mcConfig.mode $modes) -}}
    {{- fail (printf "Minecraft - Expected [Mode] to be one of [%s], but got [%s]" (join ", " $modes) .Values.mcConfig.mode) -}}
  {{- end -}}

  {{- $lvlTypes := (list "minecraft:default" "minecraft:flat" "minecraft:large_biomes"
                          "minecraft:amplified" "minecraft:single_biome_surface" "buffet" "customized") -}}
  {{- if not (mustHas .Values.mcConfig.levelType $lvlTypes) -}}
    {{- fail (printf "Minecraft - Expected [Level Type] to be one of [%s], but got [%s]" (join ", " $lvlTypes) .Values.mcConfig.levelType) -}}
  {{- end -}}

{{- end -}}
