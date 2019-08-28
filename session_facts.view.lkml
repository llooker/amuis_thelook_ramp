view: session_facts {
  derived_table: {
    sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ;;
    distribution: "unique_session_id"
    sortkeys: ["session_start"]
    sql: WITH session_facts AS
        (
          SELECT
             unique_session_id
            , logs_with_session_info.created_at
            , user_id
            , ip_address
            , uri
            , event_id
            , event_type
            , COALESCE(user_id::varchar, ip_address) as identifier
            , FIRST_VALUE (created_at) OVER (PARTITION BY unique_session_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_start
            , LAST_VALUE (created_at) OVER (PARTITION BY unique_session_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_end
            , FIRST_VALUE (event_type) OVER (PARTITION BY unique_session_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_landing_page
            , LAST_VALUE  (event_type) OVER (PARTITION BY unique_session_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_exit_page
          FROM
              ${events_sessionized.SQL_TABLE_NAME} AS logs_with_session_info
          GROUP BY 1,2,3,4,5,6, 7
          ORDER BY unique_session_id asc
        )
      SELECT
        session_facts.unique_session_id
        , session_facts.identifier
        , session_facts.session_start
        , session_facts.session_end
        , session_landing_page
        , session_exit_page
        , ROW_NUMBER () OVER (PARTITION BY session_facts.identifier ORDER BY MIN(session_start)) AS session_sequence_for_user
        , ROW_NUMBER () OVER (PARTITION BY session_facts.identifier ORDER BY MIN(session_start) desc) AS inverse_session_sequence_for_user
        , count(1) as events_in_session
      FROM session_facts
      INNER JOIN
        ${events_sessionized.SQL_TABLE_NAME} AS logs_with_session_info
      ON
        logs_with_session_info.created_at = session_facts.session_start
        AND logs_with_session_info.unique_session_id = session_facts.unique_session_id
      GROUP BY 1,2,3,4,5,6
      ORDER BY session_start asc
       ;;
  }

  dimension: unique_session_id {
    hidden: yes
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension_group: session_start_at {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_end_at {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_end ;;
  }

  dimension: session_sequence_for_user {
    type: number
    sql: ${TABLE}.session_sequence_for_user ;;
  }

  dimension: inverse_session_sequence_for_user {
    type: number
    sql: ${TABLE}.inverse_session_sequence_for_user ;;
  }

  dimension: number_of_events_in_session {
    type: number
    sql: ${TABLE}.events_in_session ;;
  }

  dimension: session_landing_page {
    type: string
    sql: ${TABLE}.session_landing_page ;;
  }

  dimension: session_exit_page {
    type: string
    sql: ${TABLE}.session_exit_page ;;
  }

  dimension: session_length_seconds {
    type: number
    sql: DATEDIFF('sec', ${TABLE}.session_start, ${TABLE}.session_end) ;;
  }

  dimension: session_length_seconds_tier {
    type: tier
    tiers: [
      0,
      15,
      30,
      45,
      60,
      75,
      100
    ]
    sql: ${session_length_seconds} ;;
  }

  measure: average_session_length_seconds {
    type: average
    sql: ${session_length_seconds} ;;
  }

  measure: session_facts_count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      unique_session_id,
      session_start_at_time,
      session_end_at_time,
      session_sequence_for_user,
      inverse_session_sequence_for_user,
      number_of_events_in_session,
      session_landing_page,
      session_exit_page
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

# view: session_facts {
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
