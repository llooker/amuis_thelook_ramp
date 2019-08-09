- dashboard: Anouks_first_lookml_dashboard
  title: Anouks First Lookml Dashboard
  layout: tile
  tile_size: 100

  filters:

  elements:
  - name: hello_world
    type: looker_column

  - name: add_a_unique_name_1565339029
    title: Untitled Visualization
    model: anouk_thelook_ramp
    explore: events
    type: looker_scatter
    fields: [events.east_coast_count, users.age_group, events.count]
    fill_fields: [users.age_group]
    filters:
    users.country: USA
    sorts: [events.east_coast_count desc]
    limit: 500
    query_timezone: America/Los_Angeles
    series_types: {}

  - name: my_first_waterfall
    title: Untitled Visualization
    model: anouk_thelook_ramp
    explore: events
    type: looker_waterfall
    fields: [events.count, users.traffic_source]
    filters:
    users.country: USA
    sorts: [events.count desc]
    limit: 500
    query_timezone: America/Los_Angeles
    series_types: {}
    up_color: "#173589"
    down_color: "#3EB0D5"
    total_color: "#1E0030"
