view: inventory_items {
  sql_table_name: public.inventory_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
    value_format: "$0.00"
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}.product_brand ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}.product_category ;;
  }

  dimension: product_brand_cat {
      type: string
      sql:  ${TABLE}.product_brand || ' ' || ${TABLE}.product_category ;;
  }

  dimension: product_department {
    type: string
    sql: ${TABLE}.product_department ;;
  }

  dimension: product_distribution_center_id {
    type: number
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: product_retail_price {
    type: number
    sql: ${TABLE}.product_retail_price ;;
  }

  dimension: product_sku {
    type: string
    sql: ${TABLE}.product_sku ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.sold_at ;;
  }

  measure: count {
    type: count
    drill_fields: [id, product_name, products.id, products.name, order_items.count]
  }

  measure: total_cost {
    #As far as I'm aware inventory_items is a normalized table, sum_distinct solely for tick-the-box-purpose exercise
    drill_fields: [product_department, product_brand, product_name, product_retail_price]
    type: sum_distinct
    sql: ${cost} ;;
    value_format: "$0.00"
  }

  measure: total_cost_womens_department {
    type: sum
    drill_fields: [product_brand, product_category, cost]
    filters: {
      field: product_department
      value: "Women"
    }
    sql: ${cost} ;;
    value_format: "$0.00"
  }

  measure: total_cost_mens_department {
    type: sum
    drill_fields: [product_brand, product_category, cost]
    filters: {
      field: product_department
      value: "Men"
    }
    value_format: "$0.00"
    sql: ${cost} ;;
  }
}
