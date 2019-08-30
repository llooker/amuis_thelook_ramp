view: order_facts {
  derived_table: {
    sql: SELECT order_id, user_id, COUNT(*) as item_count, SUM(sale_price) as order_total
      FROM   public.order_items
      GROUP BY order_id, user_id
      ORDER BY 3 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: item_count {
    type: number
    sql: ${TABLE}.item_count ;;
  }

  dimension: order_total {
    type: number
    sql: ${TABLE}.order_total ;;
    value_format_name: usd
  }

  measure: average_item_count {
    type: average
    sql: ${item_count} ;;
    value_format_name: decimal_2
  }

  set: detail {
    fields: [order_id, user_id, item_count, order_total, average_item_count]
  }
}
