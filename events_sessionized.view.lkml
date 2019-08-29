view: events_sessionized {
    view_label: "Events"

    derived_table: {
      sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ;;
      distribution: "event_id"
      sortkeys: ["created_at"]
      sql: SELECT
              ROW_NUMBER() OVER (ORDER BY log.created_at) AS event_id
            , log.ip_address
            , log.user_id
            , log.os
            , log.uri
            , log.event_type
            , log.browser
            , log.traffic_source
            , log.created_at
            , sessions.unique_session_id
            , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY log.created_at) AS event_sequence_within_session
            , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY log.created_at desc) AS inverse_event_sequence_within_session
        FROM public.events AS log
        INNER JOIN ${sessions.SQL_TABLE_NAME} AS sessions
          ON log.user_id = sessions.user_id
          AND log.ip_address = sessions.ip_address
          AND log.created_at >= sessions.session_start
          AND log.created_at < sessions.next_session_start
        WHERE
          ((log.created_at) >= (DATEADD(day,-59, DATE_TRUNC('day',GETDATE()) ))  AND (log.created_at) < (DATEADD(day,60, DATEADD(day,-59, DATE_TRUNC('day',GETDATE()) ) )))
         ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: event_id {
      primary_key: yes
      type: number
      value_format_name: id
      sql: ${TABLE}.event_id ;;
    }

    dimension: user_id {
      type: number
      sql: ${TABLE}.user_id ;;
    }

    dimension: unique_session_id {
      type: number
      value_format_name: id
      hidden: yes
      sql: ${TABLE}.unique_session_id ;;
    }

    dimension: page_name {
      type: string
      sql: ${TABLE}.uri ;;
    }

    dimension: event_type {
      label: "Event Type (Sessionized)"
      type: string
      sql: ${TABLE}.event_type ;;
    }

    dimension: traffic_source {
      type: string
      sql: ${TABLE}.traffic_source ;;
    }

    dimension: event_sequence_within_session {
      type: number
      value_format_name: id
      sql: ${TABLE}.event_sequence_within_session ;;
    }

    dimension: inverse_event_sequence_within_session {
      type: number
      value_format_name: id
      sql: ${TABLE}.inverse_event_sequence_within_session ;;
    }

    set: detail {
      fields: [
        event_id,
        #ip_address,
        user_id,
        #os,
        traffic_source,
        #event_time_time,
        unique_session_id,
        event_sequence_within_session,
        inverse_event_sequence_within_session,
        #user_first_session_time,
        #session_landing_page,
        #session_exit_page
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

# view: events_sessionized {
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
