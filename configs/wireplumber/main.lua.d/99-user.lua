table.insert (alsa_monitor.rules, {
  matches = {
    {
      -- Matches all sources.
      { "node.name", "matches", "alsa_input.*" },
    },
    {
      -- Matches all sinks.
      { "node.name", "matches", "alsa_output.*" },
    },
  },
  apply_properties = {
    ["node.pause-on-idle"] = false,
    ["session.suspend-timeout-seconds"] = 0,  -- 0 disables suspend
    --["audio.rate"] = 48000,
    --["audio.allowed-rates"] = "44100,48000",
    --["api.alsa.headroom"] = 1024,
    --["api.alsa.period-num"] = 1,
    --["api.alsa.period-size"] = 2048,
  },
})
