view: customer_ltv {
  label: "Customer LTV"
  derived_table: {
    sql: SELECT user_id, COUNT(distinct order_items.order_id) as total_orders, SUM(sale_price) as total_sales, MIN(created_at) as first_order_date, MAX(created_at) as last_order_date
      FROM public.order_items
      GROUP BY user_id
      ORDER BY 2 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: total_orders {
    type: number
    sql: ${TABLE}.total_orders ;;
  }

  dimension: total_sales {
    type: number
    sql: ${TABLE}.total_sales ;;
  }

  dimension_group: first_order_date {
    type: time
    sql: ${TABLE}.first_order_date ;;
  }

  dimension_group: last_order_date {
    type: time
    sql: ${TABLE}.last_order_date ;;
  }

  dimension: customer_lifetime_days {
    type: number
    sql: DATEDIFF(day, ${first_order_date_date}, ${last_order_date_date}) ;;
    value_format_name: decimal_0
  }

  measure: average_lifetime_value {
    type: average
    sql: ${total_sales} ;;
    value_format_name: usd
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${total_orders} ;;
    value_format_name: decimal_2
  }

  set: detail {
    fields: [user_id, total_orders, total_sales, first_order_date_time, last_order_date_time]
  }
}
