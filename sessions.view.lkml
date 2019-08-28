view: sessions {
  derived_table: {
    sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ;;
    distribution: "user_id"
    sortkeys: ["session_start"]
    sql: WITH lag AS
        (SELECT
                  logs.created_at AS created_at
                , logs.user_id AS user_id
                , logs.ip_address AS ip_address
                , DATEDIFF(
                    minute,
                    LAG(logs.created_at) OVER ( PARTITION BY logs.user_id, logs.ip_address ORDER BY logs.created_at)
                  , logs.created_at) AS idle_time
              FROM public.events as logs
              WHERE ((logs.created_at) >= (DATEADD(day,-59, DATE_TRUNC('day',GETDATE()) ))
                    AND (logs.created_at) < (DATEADD(day,60, DATEADD(day,-59, DATE_TRUNC('day',GETDATE()) ) ))) -- optional limit of events table to only past 60 days
              )
        SELECT
          lag.created_at AS session_start
          , lag.idle_time AS idle_time
          , lag.user_id AS user_id
          , lag.ip_address AS ip_address
          , ROW_NUMBER () OVER (ORDER BY lag.created_at) AS unique_session_id
          , ROW_NUMBER () OVER (PARTITION BY COALESCE(lag.user_id::varchar, lag.ip_address) ORDER BY lag.created_at) AS session_sequence
          , COALESCE(
                LEAD(lag.created_at) OVER (PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.created_at)
              , '6000-01-01') AS next_session_start
        FROM lag
        WHERE (lag.idle_time > 60 OR lag.idle_time IS NULL)  -- session threshold (currently set at 60 minutes)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: session_start_at {
    type: time
    hidden: yes
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_start ;;
  }

  dimension: idle_time {
    type: number
    value_format: "0"
    sql: ${TABLE}.idle_time ;;
  }

  dimension: unique_session_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension: session_sequence {
    type: number
    value_format_name: id
    sql: ${TABLE}.session_sequence ;;
  }

  dimension_group: next_session_start_at {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.next_session_start ;;
  }

  measure: count_distinct_sessions {
    type: count_distinct
    sql: ${unique_session_id} ;;
  }

  set: detail {
    fields: [
      session_start_at_time,
      idle_time,
      unique_session_id,
      session_sequence,
      next_session_start_at_time
    ]
}

  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: sessions {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
