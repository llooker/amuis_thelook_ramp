view: inventory_facts {
  derived_table: {
    sql: SELECT product_SKU, SUM(CASE WHEN sold_at IS NOT NULL THEN cost ELSE NULL END) as cost_of_goods_sold, SUM(cost) as total_cost_inventory
          FROM public.inventory_items
              GROUP BY 1
             ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product_sku {
    primary_key: yes
    type: string
    sql: ${TABLE}.product_sku ;;
  }

  dimension: cost_of_goods_sold {
    type: number
    sql: ${TABLE}.cost_of_goods_sold ;;
  }

  dimension: total_cost_inventory {
    type: number
    sql: ${TABLE}.total_cost_inventory ;;
  }

  dimension: pct_inv_sold {
    type: number
    sql: 1.0 * NULLIF(${cost_of_goods_sold},0) / (1.0* NULLIF(${total_cost_inventory},0));;
    value_format_name: percent_2
  }

  measure: inventory_on_hand {
    type: sum
    sql: ${total_cost_inventory} - ${cost_of_goods_sold};;
    value_format_name: usd
  }

  measure:avg_percentage_inventory_sold {
    type: average
    sql: ${pct_inv_sold} ;;
    value_format_name: percent_2
    #Implement colour coding for overstocked product categories/brands
#    html: <p style="color: black; background-color: rgba({{ value | times: -100.0 | round | plus: 250 }},{{value | times: 100.0 | round | plus: 100}},100,80); font-size:100%; text-align:center">{{ rendered_value }}</p> ;;
  }

  set: detail {
    fields: [product_sku, cost_of_goods_sold, total_cost_inventory, pct_inv_sold]
  }
}
